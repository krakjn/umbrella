use serde::Deserialize;

// command line interface

#[derive(Debug, Deserialize)]
struct Schema {
    greeting: String,
    name: String,
    version: String,
}

fn main() {
    let schema: Schema =
        serde_json::from_str(include_str!("../schema.json")).expect("schema.json");
    println!(
        "{} {} ({})",
        schema.greeting, schema.name, schema.version
    );
}
