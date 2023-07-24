# MibiMdEditor

## Description

I entirely rewrote the editor in **two days**, and I only used GTK3 **one time before**, with python, and it's the **first time** I wrote a real app in Vala, so **don't expect too much** !

A simple Markdown editor written in Vala with GTK 4

See TODO.md for upcoming features.

## Screenshots

### v.0.4-a2 : Syntax highlighting and undo/redo buttons + shotcuts

![v.0.4-a2](screenshots/mibimdeditor_v04a2.png)

### v.0.4-a1 : First version of MibiMdEditor written in vala

![v.0.4-a1](screenshots/mibimdeditor_v04a1.png)

## Compiling

This project requires
* Vala
* GTK 4
* libadwaita 1

Compile it using meson :

```
$ meson setup bin
$ cd bin
$ meson compile
$ meson install
```

Then just run the binary in bin/src/.

