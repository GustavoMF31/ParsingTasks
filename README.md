# ParsingTasks
Parsing a language for describing tasks

[README em português](README.pt-br.md)

This is a simple project I made to learn a bit about parsing and parser combinators. The parsed language looks like the following:
```
Organize the backpack {
    . Math notebook
    . Science notebook
    . Biology notebook
}

Have coffee {
    . Set the table
    . Brush teeth
}

Morning routine {
    - Organize the backpack
    - Have coffee
}
```

Tasks started with a dot are simple tasks: They just have a name.
Those that start with a dash are compound tasks, made up of simple tasks and other compound tasks
This way a task that's part of many others can be "factored out" and reused, while huge tasks can be expressed as the composition of many small ones.

A couple things missing are proper handling of name collisions and detecting infinite task recursion.
