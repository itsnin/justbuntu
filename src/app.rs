use crossterm::event::{KeyCode, KeyEvent, KeyModifiers};

#[derive(Clone, Copy)]
pub enum SelectionMode {
    Single,
    Multiple,
}

#[derive(Clone, Copy)]
pub enum InputKind {
    Text,
    Password,
}

pub enum ScreenResult {
    Selection(Vec<String>),
    Confirmation(bool),
    Input(String),
}

pub struct App {
    pub title: String,
    pub items: Vec<String>,
    pub selected: Vec<bool>,
    pub cursor: usize,
    pub screen: Screen,
    pub should_quit: bool,
}

pub enum Screen {
    Selection(SelectionMode),
    Confirmation { answer: bool },
    Input { kind: InputKind, value: String },
}

impl App {
    pub fn selection(
        title: String,
        items: Vec<String>,
        selected_items: Vec<String>,
        mode: SelectionMode,
    ) -> Self {
        let selected = items
            .iter()
            .map(|item| selected_items.iter().any(|selected| selected == item))
            .collect();
        Self {
            title,
            items,
            selected,
            cursor: 0,
            screen: Screen::Selection(mode),
            should_quit: false,
        }
    }

    pub fn confirmation(title: String, default_yes: bool) -> Self {
        Self {
            title,
            items: Vec::new(),
            selected: Vec::new(),
            cursor: 0,
            screen: Screen::Confirmation {
                answer: default_yes,
            },
            should_quit: false,
        }
    }

    pub fn input(title: String, value: String, kind: InputKind) -> Self {
        Self {
            title,
            items: Vec::new(),
            selected: Vec::new(),
            cursor: 0,
            screen: Screen::Input { kind, value },
            should_quit: false,
        }
    }

    pub fn handle_key(&mut self, key: KeyEvent) {
        if key.modifiers.contains(KeyModifiers::CONTROL) && key.code == KeyCode::Char('c') {
            self.should_quit = true;
            return;
        }
        let screen_kind = match &self.screen {
            Screen::Selection(mode) => Some(*mode),
            _ => None,
        };
        if let Some(mode) = screen_kind {
            self.handle_selection_key(key, mode);
            return;
        }
        match &mut self.screen {
            Screen::Selection(_) => unreachable!("selection was handled before this match"),
            Screen::Confirmation { answer, .. } => match key.code {
                KeyCode::Left | KeyCode::Right | KeyCode::Char('h') | KeyCode::Char('l') => {
                    *answer = !*answer
                }
                KeyCode::Enter | KeyCode::Char(' ') => self.should_quit = true,
                KeyCode::Esc | KeyCode::Char('q') => {
                    *answer = false;
                    self.should_quit = true;
                }
                _ => {}
            },
            Screen::Input { value, .. } => match key.code {
                KeyCode::Enter => self.should_quit = true,
                KeyCode::Esc => {
                    value.clear();
                    self.should_quit = true;
                }
                KeyCode::Backspace => {
                    value.pop();
                }
                KeyCode::Char(character) => value.push(character),
                _ => {}
            },
        }
    }

    fn handle_selection_key(&mut self, key: KeyEvent, mode: SelectionMode) {
        match key.code {
            KeyCode::Up | KeyCode::Char('k') => {
                self.cursor = self.cursor.checked_sub(1).unwrap_or(self.items.len() - 1);
            }
            KeyCode::Down | KeyCode::Char('j') => {
                self.cursor = (self.cursor + 1) % self.items.len();
            }
            KeyCode::Char(' ') => match mode {
                SelectionMode::Single => {
                    self.selected.fill(false);
                    self.selected[self.cursor] = true;
                }
                SelectionMode::Multiple => self.selected[self.cursor] = !self.selected[self.cursor],
            },
            KeyCode::Enter => self.should_quit = true,
            KeyCode::Esc | KeyCode::Char('q') => {
                self.selected.fill(false);
                self.should_quit = true;
            }
            _ => {}
        }
    }

    pub fn result(&self) -> ScreenResult {
        match &self.screen {
            Screen::Selection(_) => ScreenResult::Selection(
                self.items
                    .iter()
                    .zip(&self.selected)
                    .filter_map(|(item, selected)| selected.then_some(item.clone()))
                    .collect(),
            ),
            Screen::Confirmation { answer, .. } => ScreenResult::Confirmation(*answer),
            Screen::Input { value, .. } => ScreenResult::Input(value.clone()),
        }
    }
}

impl ScreenResult {
    #[cfg(test)]
    fn selection(&self) -> Vec<String> {
        match self {
            Self::Selection(items) => items.clone(),
            _ => Vec::new(),
        }
    }

    #[cfg(test)]
    fn confirmation(&self) -> Option<bool> {
        match self {
            Self::Confirmation(answer) => Some(*answer),
            _ => None,
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn key(code: KeyCode) -> KeyEvent {
        KeyEvent::new(code, KeyModifiers::NONE)
    }

    #[test]
    fn space_toggles_multiple_selection() {
        let mut app = App::selection(
            "test".to_owned(),
            vec!["One".to_owned(), "Two".to_owned()],
            Vec::new(),
            SelectionMode::Multiple,
        );
        app.handle_key(key(KeyCode::Char(' ')));
        assert_eq!(app.result().selection(), vec!["One"]);
        app.handle_key(key(KeyCode::Char(' ')));
        assert_eq!(app.result().selection(), Vec::<String>::new());
    }

    #[test]
    fn enter_submits_current_selection() {
        let mut app = App::selection(
            "test".to_owned(),
            vec!["One".to_owned()],
            vec!["One".to_owned()],
            SelectionMode::Multiple,
        );
        app.handle_key(key(KeyCode::Enter));
        assert!(app.should_quit);
    }

    #[test]
    fn confirmation_defaults_to_yes() {
        let app = App::confirmation("test".to_owned(), true);
        assert_eq!(app.result().confirmation(), Some(true));
    }
}
