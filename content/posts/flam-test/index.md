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

# First
```rust {style=onedark}
use actix_web::body::BoxBody;
use actix_web::http::StatusCode;
use actix_web::{HttpResponse, HttpResponseBuilder, ResponseError};


// Testing a comment
#[derive(Debug, Error)]
pub enum BackendError {
    #[error("Project with name `{0}` already exists")]
    ProjectExists(String),
    #[error("Project with id `{0}` doesn't exist")]
    ProjectIdDoesntExist(i64),
    #[error("Project has been archived")]
    ProjectArchived,
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

# Second
```rust {style=base16-snazzy}
use actix_web::body::BoxBody;
use actix_web::http::StatusCode;
use actix_web::{HttpResponse, HttpResponseBuilder, ResponseError};


// Testing a comment
#[derive(Debug, Error)]
pub enum BackendError {
    #[error("Project with name `{0}` already exists")]
    ProjectExists(String),
    #[error("Project with id `{0}` doesn't exist")]
    ProjectIdDoesntExist(i64),
    #[error("Project has been archived")]
    ProjectArchived,
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

# Third
```rust {style=github-dark}
use actix_web::body::BoxBody;
use actix_web::http::StatusCode;
use actix_web::{HttpResponse, HttpResponseBuilder, ResponseError};

// Testing a comment
#[derive(Debug, Error)]
pub enum BackendError {
    #[error("Project with name `{0}` already exists")]
    ProjectExists(String),
    #[error("Project with id `{0}` doesn't exist")]
    ProjectIdDoesntExist(i64),
    #[error("Project has been archived")]
    ProjectArchived,
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

# Fourth
```rust {style=catppuccin-mocha}
use actix_web::body::BoxBody;
use actix_web::http::StatusCode;
use actix_web::{HttpResponse, HttpResponseBuilder, ResponseError};

// Testing a comment
#[derive(Debug, Error)]
pub enum BackendError {
    #[error("Project with name `{0}` already exists")]
    ProjectExists(String),
    #[error("Project with id `{0}` doesn't exist")]
    ProjectIdDoesntExist(i64),
    #[error("Project has been archived")]
    ProjectArchived,
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

# Fifth
```rust {style=catppuccin-frappe}
use actix_web::body::BoxBody;
use actix_web::http::StatusCode;
use actix_web::{HttpResponse, HttpResponseBuilder, ResponseError};

// Testing a comment
#[derive(Debug, Error)]
pub enum BackendError {
    #[error("Project with name `{0}` already exists")]
    ProjectExists(String),
    #[error("Project with id `{0}` doesn't exist")]
    ProjectIdDoesntExist(i64),
    #[error("Project has been archived")]
    ProjectArchived,
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

# Sixth
```rust {style=catppuccin-latte}
use actix_web::body::BoxBody;
use actix_web::http::StatusCode;
use actix_web::{HttpResponse, HttpResponseBuilder, ResponseError};

// Testing a comment
#[derive(Debug, Error)]
pub enum BackendError {
    #[error("Project with name `{0}` already exists")]
    ProjectExists(String),
    #[error("Project with id `{0}` doesn't exist")]
    ProjectIdDoesntExist(i64),
    #[error("Project has been archived")]
    ProjectArchived,
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

# Seventh
```rust {style=catppuccin-macchiato}
use actix_web::body::BoxBody;
use actix_web::http::StatusCode;
use actix_web::{HttpResponse, HttpResponseBuilder, ResponseError};

// Testing a comment
#[derive(Debug, Error)]
pub enum BackendError {
    #[error("Project with name `{0}` already exists")]
    ProjectExists(String),
    #[error("Project with id `{0}` doesn't exist")]
    ProjectIdDoesntExist(i64),
    #[error("Project has been archived")]
    ProjectArchived,
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