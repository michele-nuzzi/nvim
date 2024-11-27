# nvim configuration

## notes on using the config with `termux`

termux uses a different organizations of files than normal.

This is done purposefuly (afaik) so that termux can operate without root access.

however this means that shebangs need to be modified manually.

in particular for the typescript lsp to work [you will need to manually modify the shebang](https://github.com/neovim/neovim/issues/25712#issuecomment-177613828)

to do so locate `typescript-language-server` (if neovim doesn't already tell you the full path) 

```bash
which typescript-language-server
```

and modify the first line to:


```ts
#!/data/data/com.termux/files/usr/bin/node
// #!/usr/bin/env node
```

