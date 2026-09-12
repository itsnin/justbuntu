use ratatui::{
    Frame,
    layout::{Constraint, Direction, Layout, Rect},
    style::{Color, Modifier, Style},
    text::{Line, Span},
    widgets::{Block, Borders, List, ListItem, ListState, Paragraph, Wrap},
};

use crate::app::{App, InputKind, Screen, SelectionMode};

pub fn draw(frame: &mut Frame, app: &App) {
    let area = centered(frame.area(), 80, 16);
    match &app.screen {
        Screen::Selection(mode) => draw_selection(frame, area, app, *mode),
        Screen::Confirmation { answer } => draw_confirmation(frame, area, app, *answer),
        Screen::Input { kind, value } => draw_input(frame, area, app, *kind, value),
    }
}

fn draw_selection(frame: &mut Frame, area: Rect, app: &App, mode: SelectionMode) {
    let items = app
        .items
        .iter()
        .zip(&app.selected)
        .map(|(item, selected)| {
            let marker = if *selected { "[x]" } else { "[ ]" };
            ListItem::new(Line::from(format!("{marker} {item}")))
        })
        .collect::<Vec<_>>();
    let mut state = ListState::default();
    state.select(Some(app.cursor));
    let help = match mode {
        SelectionMode::Multiple => "↑/↓ move   Space select/deselect   Enter confirm   Esc cancel",
        SelectionMode::Single => "↑/↓ move   Space select   Enter confirm   Esc cancel",
    };
    let block = Block::default()
        .title(format!(" {} ", app.title))
        .title_bottom(Line::from(help).centered())
        .borders(Borders::ALL)
        .border_style(Style::default().fg(Color::Cyan));
    frame.render_stateful_widget(List::new(items).block(block), area, &mut state);
}

fn draw_confirmation(frame: &mut Frame, area: Rect, app: &App, answer: bool) {
    let text = vec![
        Line::from(app.title.as_str()),
        Line::from(""),
        Line::from(vec![
            Span::styled(if answer { "[Yes]" } else { " Yes " }, choice_style(answer)),
            Span::raw("  "),
            Span::styled(if !answer { "[No]" } else { " No " }, choice_style(!answer)),
        ]),
    ];
    let paragraph = Paragraph::new(text)
        .block(
            Block::default()
                .title(" Confirm ")
                .title_bottom(Line::from("←/→ choose   Enter confirm   Esc cancel").centered())
                .borders(Borders::ALL)
                .border_style(Style::default().fg(Color::Cyan)),
        )
        .alignment(ratatui::layout::Alignment::Center)
        .wrap(Wrap { trim: true });
    frame.render_widget(paragraph, area);
}

fn draw_input(frame: &mut Frame, area: Rect, app: &App, kind: InputKind, value: &str) {
    let shown = match kind {
        InputKind::Password => "•".repeat(value.chars().count()),
        InputKind::Text => value.to_owned(),
    };
    let paragraph = Paragraph::new(shown)
        .block(
            Block::default()
                .title(format!(" {} ", app.title))
                .title_bottom(Line::from("Enter confirm   Esc cancel").centered())
                .borders(Borders::ALL)
                .border_style(Style::default().fg(Color::Cyan)),
        )
        .style(Style::default().add_modifier(Modifier::BOLD));
    frame.render_widget(paragraph, area);
}

fn choice_style(selected: bool) -> Style {
    if selected {
        Style::default()
            .fg(Color::Black)
            .bg(Color::Cyan)
            .add_modifier(Modifier::BOLD)
    } else {
        Style::default().fg(Color::Gray)
    }
}

fn centered(area: Rect, width: u16, height: u16) -> Rect {
    let vertical = Layout::default()
        .direction(Direction::Vertical)
        .constraints([Constraint::Length(height), Constraint::Min(0)])
        .split(area);
    Layout::default()
        .direction(Direction::Horizontal)
        .constraints([Constraint::Length(width), Constraint::Min(0)])
        .split(vertical[0])[0]
}
