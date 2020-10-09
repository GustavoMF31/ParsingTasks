# ParsingTasks
Parsing de uma linguagem para descrever tarefas

Esse é um projeto simples que eu fiz para aprender um pouco sobre parsing e parsing combinators. A linguagem parseada é assim:
```
Organizar a mochila {
    . Caderno de matemática
    . Caderno de ciências
    . Caderno de biologia
}

Tomar café {
    . Colocar a mesa
    . Escovar os dentes
}

Rotina matinal {
    - Organizar a mochila
    - Tomar café
}
```

Tarefas que começam com um ponto são tarefas simples: elas tem apenas um nome.
Aquelas que começam com um traço são tarefas compostas, feitas de outras tarefas compostas e de tarefas simples.

Dessa maneira uma tarefa que faz parte de várias outras pode ser "refatorada" e reutilizada, enquanto tarefas grandes podem ser expressas como a composição de várias tarefas pequenas.

Algumas coisas faltando são o tratamento de colisões de nome e a detecção de recursão infinita de tarefas.
