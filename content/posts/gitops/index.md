+++
date = '2025-08-24T13:50:00+01:00'
draft = false
title = 'Server management for 10x devs with GitOps'
authors = ["Say"]
+++
## Introduction

So, I recently got into selfhosting. I rented a tiny cloud server, that I use to run some stuff like [paperless](https://docs.paperless-ngx.com/),
[vaultwarden](https://github.com/dani-garcia/vaultwarden) or [trilium](https://github.com/TriliumNext/Trilium).
I have a computer science background, so I had dipped into containers before
and a few friends use them to run pretty much everything they host, so I decided to try the same.

I use [podman](https://podman.io/) and podman-compose for that, which, if you are unfamiliar with it,
enables me to write small yaml files like this to describe the containers required for an app,
how they interlink with the host and what they do.
This provides you with a declarative description of your system which helps you to easily keep track of the services you are running
so you don't have to keep random docker run commands lying around everywhere.

That went surprisingly well for a few weeks but then my software engineering background caught up to me:
I noticed that I had gathered a reasonable amount of compose files and wanted to put them into some kind of version control
as software engineers tend to do with everything.
I snooped around for a bit and then got told to check out GitOps.

## What is GitOps?

[According to Redhat](https://www.redhat.com/en/topics/devops/what-is-gitops):
> GitOps is a set of practices  for managing infrastructure and application configurations to expand upon existing processes and improve the application lifecycle.

Now, what they were trying to say is, that GitOps helps you to easily version control and manage your server(s) and their services via a git repo and some CI/CD pipelines.
And, even though it has strong roots in the kubernetes domain, I still thought it was neat and wanted to give it a spin.

## Deep dive

I like to readup on topics like this before starting out, and found this nice diagram in [a book](https://leanpub.com/gitops/).
Let's start from the bottom:

![img.png](gitops-architecture.png)

You have your environment, which to my understanding is just your server in general.
The deployment is part of that and consists of all services and applications deployed on it that are managed through you GitOps.
We describe that in the environment repository ([here is mine if you are interested](https://github.com/0815Sailsman/turing-environment), which is just a collection of all the compose files and container descriptions for a concrete server.
Changing something in there triggers a pipeline, that causes an update in the deployment.
If you deploy your own apps, you can use the application repo and a corresponding pipeline to update the env repo on changes,
but that is slightly optional if you use something like [renovate](https://github.com/apps/renovate) to notify you when new updates are available for your containers.

This looks great already, but if you paid attention, the one thing that's missing is a way for the server to actually listen to what the repos tell them
and reflect that onto the deployment. So… the next obvious step is to write a webapp that handles this.

## Collecting requirements

The premise is simple:
When we receive an update request we check the env repo by pulling it locally.
We then compute a hash for each service directory and compare that hash with the one for the currently deployed service.
That way, we can notice, when a service has been updated. If that is the case, we update the image and redeploy it.
Because all that is just fancy commandline magic, my first idea was to just write an AIO shell script, that pretty much gets exposed via an HTTP endpoint.
As we will discuss later, that was a terrible idea. But for now it gets the job done and is how things got implemented.

## Implementation

For reference, see [the repo](https://github.com/0815sailsman/gitops-deploy-server).

For the techstack I decided to write my app with [ktor](https://ktor.io/), which is pretty much just spring boot without all the slack.
I can't really recommend it enough, this is my 4th project using it and it just gets better every time.

There is not much to see on the code side, so we will go over it very quickly:
We have 2 endpoints now, one for the previously mentioned use case, that just updates the env repo and checks all services for changes,
and one for checking and redeploying a single service, because I thought that this might help for using this app as a CD provider later on.

### Endpoint for general updates
```kotlin {style=catppuccin-mocha}
route("/deploy-all-changed") {
            post {
                log.info("Request to deploy all changes arrived...")
                val signatureHeader = call.request.headers["X-Hub-Signature-256"]
                val rawPayload = call.receive<ByteArray>()

                if (!HmacVerifier.isValidSha256Signature(rawPayload, signatureHeader, webhookSecret)) {
                    log.info("Invalid signature")
                    call.respond(HttpStatusCode.Unauthorized, "Invalid signature")
                    return@post
                }

                val process = ProcessBuilder("./deploy-all-changed.sh")
                    .directory(File("/"))
                    .redirectOutput(ProcessBuilder.Redirect.INHERIT)
                    .redirectError(ProcessBuilder.Redirect.INHERIT)
                    .start()

                call.respond(HttpStatusCode.OK, "Deploy triggered...")

                val exitCode = process.waitFor()
                log.info("Script returned")

                if (exitCode == 0) {
                    log.info("Deploy successful")
                } else {
                    log.info("Deploy Failed")
                }
            }
        }
```

### Endpoint for single service updates
```kotlin {style=catppuccin-mocha}
route("/redeploy-and-update/{service-name}") {
            post {
                log.info("Request to re-deploy and update single arrived...")
                val signatureHeader = call.request.headers["X-Hub-Signature-256"]
                val rawPayload = call.receive<ByteArray>()

                if (!HmacVerifier.isValidSha256Signature(rawPayload, signatureHeader, webhookSecret)) {
                    log.info("Invalid signature")
                    call.respond(HttpStatusCode.Unauthorized, "Invalid signature")
                    return@post
                }

                val text = String(rawPayload, Charsets.UTF_8)
                val jsonBody = Json.decodeFromString(text) as JsonObject

                log.info("action ${(jsonBody["action"] as JsonPrimitive)}")
                if ((jsonBody["action"] as JsonPrimitive).content == "published") {
                    log.info("Calling deploy script...")
                    val process = ProcessBuilder("./redeploy-and-update.sh", call.parameters["service-name"])
                        .directory(File("/"))
                        .redirectOutput(ProcessBuilder.Redirect.INHERIT)
                        .redirectError(ProcessBuilder.Redirect.INHERIT)
                        .start()

                    call.respond(HttpStatusCode.OK, "Deploy of single service triggered")

                    val exitCode = process.waitFor()
                    log.info("Script returned")

                    if (exitCode == 0) {
                        log.info("Deploy of single service successful")
                    } else {
                        log.info("Failed")
                    }
                } else {
                    log.info("Updates are not considered here...")
                    call.respond(HttpStatusCode.OK, "Did not do anything because actions was not 'published'")
                }
            }
        }
```

We use a pre shared secret as authentication, that only I will be able to trigger these changes.
The endpoints then just call into the responsible shell scripts that do the heavy lifting.

### Shell scripts
```shell {style=catppuccin-mocha}
#!/bin/bash
set -x

# Export CONTAINER_HOST for podman-compose to use remote connection
export CONTAINER_HOST=unix:///run/podman/podman.sock

echo "[GitOps] Switching to env-repo..."
cd /env-repo || exit 1

echo "[GitOps] Pulling latest changes..."
git pull

# Set up podman remote connection if not already done
if ! podman system connection exists host 2>/dev/null; then
    echo "[GitOps] Setting up podman remote connection..."
    podman system connection add host $CONTAINER_HOST
    podman system connection default host
fi

# Test connection
echo "[GitOps] Testing podman connection..."
if ! podman --remote info >/dev/null 2>&1; then
    echo "[GitOps] ERROR: Cannot connect to podman on host"
    echo "[GitOps] Make sure podman.socket is running: systemctl --user enable --now podman.socket"
    exit 1
fi

# Process all services except gitops-deploy-server
for dir in services/*; do
  svc_name=$(basename "$dir")
  if [[ "$svc_name" == "gitops-deploy-server" ]]; then
    continue
  fi

  echo "[GitOps] Checking service: $svc_name"
  pushd "$dir" >/dev/null || exit 1

  # Build hash from compose + env + any config
  CURRENT_HASH=$(cat podman-compose.yml .env .podman-compose.env 2>/dev/null | sha256sum | awk '{print $1}')
  LAST_HASH_FILE=".last-deploy-hash"

  if [[ ! -f "$LAST_HASH_FILE" ]] || [[ "$CURRENT_HASH" != "$(cat $LAST_HASH_FILE)" ]]; then
    echo "[GitOps] → Changes detected. Restarting $svc_name..."
    podman-compose down
    podman-compose up -d
    echo "$CURRENT_HASH" > "$LAST_HASH_FILE"
  else
    echo "[GitOps] → No changes. Skipping $svc_name."
  fi

  popd >/dev/null || exit 1
done

# --- Special handling for gitops-deploy-server (A/B self-update) ---
GITOPS_DIR="services/gitops-deploy-server"
if [[ ! -d "$GITOPS_DIR" ]]; then
  echo "[GitOps] Skipping $GITOPS_DIR: directory does not exist."
else
  INSTANCE_FILE=".active-instance"
  APP_NAME="gitops-deploy-server"

  echo "[GitOps] Checking service: $APP_NAME"
  pushd "$GITOPS_DIR" >/dev/null || exit 1

  CURRENT_HASH=$(cat podman-compose.yml .env 2>/dev/null | sha256sum | awk '{print $1}')
  LAST_HASH_FILE=".last-deploy-hash"

  if [[ ! -f "$LAST_HASH_FILE" ]] || [[ "$CURRENT_HASH" != "$(cat $LAST_HASH_FILE)" ]]; then
    echo "[GitOps] → Changes detected. Performing A/B self-update..."

    # Determine current and next instance
    if [[ -f "$INSTANCE_FILE" ]]; then
      CURRENT_INSTANCE=$(cat "$INSTANCE_FILE")
    else
      CURRENT_INSTANCE="A"
    fi
    if [[ "$CURRENT_INSTANCE" == "A" ]]; then
      NEXT_INSTANCE="B"
    else
      NEXT_INSTANCE="A"
    fi

    NEXT_CONTAINER="${APP_NAME}-${NEXT_INSTANCE}"

    if [[ "$NEXT_INSTANCE" == "A" ]]; then
      export HOST_PORT=1337
    else
      export HOST_PORT=1338
    fi

    # Update active instance file and hash
    echo "$NEXT_INSTANCE" > "$INSTANCE_FILE"
    echo "$CURRENT_HASH" > "$LAST_HASH_FILE"

    # Start new instance
    echo "[GitOps] Starting new instance: $NEXT_CONTAINER"
    podman-compose -p "$NEXT_CONTAINER" up -d
  else
    echo "[GitOps] → No changes. Skipping $APP_NAME."
  fi

  popd >/dev/null || exit 1
fi

echo "[GitOps] Deployment complete."
```

As you can see, they become pretty ugly very quickly, but they work for now, so I'll leave them be atm,
but I can't promise, that I won't come back to this and move all that logic into code at some point ;).

The host communication works by forwarding the podman socket to the container and … TODO FILL THIS OUT … which was actually simpler than expected.

To send the updates from the repos, I originally had literal GitHub Actions workflows that used curl,
but I found out that the GitHub webhooks are actually pretty cool and get the job done aswell, so I switched to them.

## Self updating

I also implemented self-updating for the app itself, which was a bit tricky, because you can't just redeploy the container that is currently running.
The solution I came up with is to run 2 instances of the app, but only one is active at a time.
When an update is detected, the inactive instance gets updated and started, while the active one gets stopped.
This is done by using a small file that just contains the currently active instance (A or B) and using that to determine which instance to start next.
The new instance then listens on a different port, so I also had to do some configs in my reverse proxy to forward the requests to the correct port.
This is done using the health endpoint of the app, to determine which instance is currently active.

## Finishing up

I also got [renovate](https://github.com/apps/renovate) setup to scream at me once new updates for my services roll out,
so I don't have to manually keep track all the time of all versions which is a lifesaver!

Future plans include migrating the shell scripts to code or building a small server side rendered frontend that displays the current status of all services.