+++
date = '2025-03-05T11:04:55+01:00'
draft = false
title = 'Flam Test'
[params]
authors = ["flam"]
+++

# Testing :333
Hello, is this thing on???

Coolest blog in the world: [is the shonks blog](https://blog.shonk.software)

Adding more lines is cool

<!--more-->

_cursive even_

**or bold?**

**_even both????_**

### Images?

![ducky here?](duck.jpg)

# Code blocks?

```rust
use actix_web::body::BoxBody;
use actix_web::http::StatusCode;
use actix_web::{HttpResponse, HttpResponseBuilder, ResponseError};
use serde::Serialize;
use thiserror::Error;
use tracing::log;
use utoipa::ToSchema;

#[derive(Debug, Error)]
pub enum BackendError {
    #[error("Project with name `{0}` already exists")]
    ProjectExists(String),
    #[error("Project with id `{0}` doesn't exist")]
    ProjectIdDoesntExist(i64),
    #[error("Project has been archived")]
    ProjectArchived,
    #[error("Team with name `{0}` already exists")]
    TeamExists(String),
    #[error("Challenge with name `{0}` already exists")]
    ChallengeExists(String),
    #[error("Challenge with id `{0}` doesn't exist")]
    ChallengeDoesntExist(i64),
    #[error("Team with id `{0}` doesn't exist")]
    TeamDoesntExist(i64),
    #[error("Entry for timed challenge requires time")]
    TimeChallengeEntryNeedsTime,
    #[error("Cannot assign more points than the challenge is worth")]
    ChallengeMaxPointsExceeded,
    #[error("Points cannot be negative")]
    PointsNegative,
    #[error("Time cannot be negative")]
    TimeNegative,
    #[error("Team with id {0} and challenge with id {1} don't belong to the same project")]
    TeamChallengeProjectDoesntMatch(i64, i64),
    #[error("Cannot specify time for PointsOnly challenge")]
    PointsOnlyHasTime,
    #[error("Incorrect Password supplied")]
    IncorrectPassword,
    #[error("Tag with specified content already exists")]
    TagWithContentExists,
    #[error("Tag with id {0} doesn't exist")]
    TagDoesntExist(i64),
    #[error(transparent)]
    Database(#[from] sqlx::Error),
    #[error(transparent)]
    Dotenvy(#[from] dotenvy::Error),
}

#[derive(Serialize, ToSchema)]
pub struct ErrorResponse {
    message: String,
    code: u16,
}

impl ResponseError for BackendError {
    fn status_code(&self) -> StatusCode {
        match self {
            Self::ProjectExists(_) => StatusCode::BAD_REQUEST,
            Self::ProjectIdDoesntExist(_) => StatusCode::NO_CONTENT,
            Self::TeamExists(_) => StatusCode::BAD_REQUEST,
            Self::TeamDoesntExist(_) => StatusCode::NOT_FOUND,
            Self::ChallengeExists(_) => StatusCode::BAD_REQUEST,
            Self::ChallengeDoesntExist(_) => StatusCode::NO_CONTENT,
            Self::TimeChallengeEntryNeedsTime => StatusCode::BAD_REQUEST,
            Self::ChallengeMaxPointsExceeded => StatusCode::BAD_REQUEST,
            Self::TeamChallengeProjectDoesntMatch(_, _) => StatusCode::BAD_REQUEST,
            Self::PointsOnlyHasTime => StatusCode::BAD_REQUEST,
            Self::PointsNegative => StatusCode::BAD_REQUEST,
            Self::TimeNegative => StatusCode::BAD_REQUEST,
            Self::IncorrectPassword => StatusCode::UNAUTHORIZED,
            Self::ProjectArchived => StatusCode::BAD_REQUEST,
            Self::TagWithContentExists => StatusCode::BAD_REQUEST,
            Self::TagDoesntExist(_) => StatusCode::BAD_REQUEST,
            _ => StatusCode::INTERNAL_SERVER_ERROR,
        }
    }

    fn error_response(&self) -> HttpResponse<BoxBody> {
        let resp = ErrorResponse {
            message: self.to_string(),
            code: self.status_code().as_u16(),
        };

        if resp.code == 500 {
            log::error!("{}", resp.message);
        }

        HttpResponseBuilder::new(self.status_code())
            .json(resp)
    }
}
```