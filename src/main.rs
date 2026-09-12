mod app;
mod protocol;
mod terminal;
mod ui;

use std::process::ExitCode;

fn main() -> ExitCode {
    match protocol::run(std::env::args().skip(1)) {
        Ok(()) => ExitCode::SUCCESS,
        Err(protocol::ProtocolError::Cancelled) => ExitCode::from(1),
        Err(error) => {
            eprintln!("justbuntu: {error}");
            ExitCode::from(1)
        }
    }
}
