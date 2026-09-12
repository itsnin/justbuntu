use std::fs::OpenOptions;
use std::io;

use crossterm::{
    event::{self, Event},
    execute,
    terminal::{EnterAlternateScreen, LeaveAlternateScreen, disable_raw_mode, enable_raw_mode},
};
use ratatui::{Terminal, backend::CrosstermBackend};

use crate::app::{App, ScreenResult};
use crate::ui;

pub fn run(app: &mut App) -> io::Result<ScreenResult> {
    let mut output = OpenOptions::new().write(true).open("/dev/tty")?;
    enable_raw_mode()?;
    execute!(output, EnterAlternateScreen)?;
    let backend = CrosstermBackend::new(output);
    let mut terminal = Terminal::new(backend)?;
    let result = run_loop(&mut terminal, app);
    let raw_mode_result = disable_raw_mode();
    let leave_screen_result = execute!(terminal.backend_mut(), LeaveAlternateScreen);
    let cursor_result = terminal.show_cursor();
    let cleanup_result = raw_mode_result.and(leave_screen_result).and(cursor_result);
    match (result, cleanup_result) {
        (Err(error), _) => Err(error),
        (Ok(value), Ok(())) => Ok(value),
        (Ok(_), Err(error)) => Err(error),
    }
}

fn run_loop(
    terminal: &mut Terminal<CrosstermBackend<std::fs::File>>,
    app: &mut App,
) -> io::Result<ScreenResult> {
    while !app.should_quit {
        terminal.draw(|frame| ui::draw(frame, app))?;
        if let Event::Key(key) = event::read()? {
            app.handle_key(key);
        }
    }
    Ok(app.result())
}
