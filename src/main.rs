use iced::{
    widget::{column, scrollable::Viewport, Column, Scrollable, Text, TextInput},
    Application, Element, Length, Padding, Pixels,
};

fn main() {
    MyApp::run(iced::Settings::default()).unwrap()
}

#[derive(Default)]
struct MyApp {
    filter_text: String,
    logs: Vec<String>,
    filtered_logs: Vec<String>,
}

#[derive(Debug, Clone)]
enum Message {
    InputChanged(String),
    Submitted,
    Scrolled(Viewport),
}

const FONT_SIZE: f32 = 30.0;

impl Application for MyApp {
    type Executor = iced::executor::Default;
    type Theme = iced::Theme;

    type Message = Message;

    type Flags = ();

    fn new(_: Self::Flags) -> (Self, iced::Command<Self::Message>) {
        let mut app = Self::default();
        app.logs.reserve(1000);
        app.filtered_logs.reserve(1000);
        for i in 0..1000 {
            app.logs.push(i.to_string());
            app.filtered_logs.push(i.to_string());
        }

        (app, iced::Command::none())
    }

    fn title(&self) -> String {
        String::from("filter")
    }

    fn update(&mut self, msg: Self::Message) -> iced::Command<Self::Message> {
        match msg {
            Message::InputChanged(s) => {
                self.filter_text = s;
            }
            Message::Submitted => {
                self.filtered_logs.clear();
                self.filtered_logs.extend(self.logs.iter().filter_map(|x| {
                    if x.contains(&self.filter_text) {
                        Some(x.clone())
                    } else {
                        None
                    }
                }));
            }
            Message::Scrolled(viewport) => {
                dbg!(viewport);
            }
        }

        iced::Command::none()
    }

    fn view(&self) -> iced::Element<'_, Self::Message, Self::Theme, iced::Renderer> {
        let input = TextInput::new("filter text", &self.filter_text)
            .padding(Padding::new(8.0))
            .on_input(Message::InputChanged)
            .on_submit(Message::Submitted)
            .on_paste(Message::InputChanged);

        let column = Column::with_children(
            self.filtered_logs
                .iter()
                .rev()
                .map(|x| Text::new(x).size(Pixels::from(FONT_SIZE)).into()),
        );
        let listview = Scrollable::new(Element::new(column))
            .width(Length::Fill)
            .on_scroll(Message::Scrolled);

        column!(input, listview).into()
    }
}
