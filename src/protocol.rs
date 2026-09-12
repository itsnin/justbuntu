use std::error::Error;
use std::fmt::{self, Display};

use crate::app::{App, InputKind, SelectionMode};

#[derive(Debug)]
pub enum ProtocolError {
    Cancelled,
    Message(String),
}

impl Display for ProtocolError {
    fn fmt(&self, formatter: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Self::Cancelled => formatter.write_str("cancelled"),
            Self::Message(message) => formatter.write_str(message),
        }
    }
}

impl Error for ProtocolError {}

pub fn run<I>(mut arguments: I) -> Result<(), ProtocolError>
where
    I: Iterator<Item = String>,
{
    let command = arguments
        .next()
        .ok_or_else(|| ProtocolError::Message(usage().to_owned()))?;
    let options: Vec<String> = arguments.collect();

    match command.as_str() {
        "select" => run_select(options),
        "confirm" => run_confirm(options),
        "input" => run_input(options),
        "--help" | "help" => {
            println!("{}", usage());
            Ok(())
        }
        _ => Err(ProtocolError::Message(format!(
            "unknown command '{command}'\n{}",
            usage()
        ))),
    }
}

fn run_select(options: Vec<String>) -> Result<(), ProtocolError> {
    let parsed = ParsedOptions::parse(options)?;
    if parsed.items.is_empty() {
        return Err(ProtocolError::Message(
            "select requires at least one item".to_owned(),
        ));
    }
    let mode = if parsed.single {
        SelectionMode::Single
    } else {
        SelectionMode::Multiple
    };
    let mut app = App::selection(parsed.title, parsed.items, parsed.selected, mode);
    match crate::terminal::run(&mut app).map_err(io_error)? {
        crate::app::ScreenResult::Selection(items) => {
            for item in items {
                println!("{item}");
            }
        }
        _ => {
            return Err(ProtocolError::Message(
                "select returned the wrong result".to_owned(),
            ));
        }
    }
    Ok(())
}

fn run_confirm(options: Vec<String>) -> Result<(), ProtocolError> {
    let parsed = ParsedOptions::parse(options)?;
    let mut app = App::confirmation(parsed.title, parsed.default_yes);
    let accepted = match crate::terminal::run(&mut app).map_err(io_error)? {
        crate::app::ScreenResult::Confirmation(answer) => answer,
        _ => {
            return Err(ProtocolError::Message(
                "confirm returned the wrong result".to_owned(),
            ));
        }
    };
    if accepted {
        Ok(())
    } else {
        Err(ProtocolError::Cancelled)
    }
}

fn run_input(options: Vec<String>) -> Result<(), ProtocolError> {
    let parsed = ParsedOptions::parse(options)?;
    let kind = if parsed.password {
        InputKind::Password
    } else {
        InputKind::Text
    };
    let mut app = App::input(parsed.title, parsed.default, kind);
    match crate::terminal::run(&mut app).map_err(io_error)? {
        crate::app::ScreenResult::Input(value) => println!("{value}"),
        _ => {
            return Err(ProtocolError::Message(
                "input returned the wrong result".to_owned(),
            ));
        }
    }
    Ok(())
}

fn io_error(error: std::io::Error) -> ProtocolError {
    ProtocolError::Message(error.to_string())
}

fn usage() -> &'static str {
    "usage: justbuntu <select|confirm|input> [options]\n\nselect options:\n  --title TEXT\n  --selected ITEM,ITEM\n  --single\n  ITEM ...\n\nconfirm options:\n  --title TEXT\n  --default yes|no\n\ninput options:\n  --title TEXT\n  --default TEXT\n  --password"
}

struct ParsedOptions {
    title: String,
    items: Vec<String>,
    selected: Vec<String>,
    default: String,
    default_yes: bool,
    password: bool,
    single: bool,
}

impl ParsedOptions {
    fn parse(options: Vec<String>) -> Result<Self, ProtocolError> {
        let mut parsed = Self {
            title: "JustBuntu".to_owned(),
            items: Vec::new(),
            selected: Vec::new(),
            default: String::new(),
            default_yes: true,
            password: false,
            single: false,
        };
        let mut iter = options.into_iter();
        while let Some(option) = iter.next() {
            match option.as_str() {
                "--title" => parsed.title = next_value(&mut iter, "--title")?,
                "--selected" => {
                    let value = next_value(&mut iter, "--selected")?;
                    parsed.selected = value
                        .split(',')
                        .filter(|item| !item.is_empty())
                        .map(str::to_owned)
                        .collect();
                }
                "--default" => {
                    let value = next_value(&mut iter, "--default")?;
                    parsed.default_yes = !matches!(value.as_str(), "no" | "false" | "0");
                    parsed.default = value;
                }
                "--password" => parsed.password = true,
                "--single" => parsed.single = true,
                value if value.starts_with('-') => {
                    return Err(ProtocolError::Message(format!("unknown option '{value}'")));
                }
                value => parsed.items.push(value.to_owned()),
            }
        }
        Ok(parsed)
    }
}

fn next_value<I>(arguments: &mut I, option: &str) -> Result<String, ProtocolError>
where
    I: Iterator<Item = String>,
{
    arguments
        .next()
        .ok_or_else(|| ProtocolError::Message(format!("{option} requires a value")))
}
