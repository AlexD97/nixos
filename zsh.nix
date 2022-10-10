{ config, pkgs, lib, ... }:
let
  rga-fzf =
    ''
      rga-fzf() {
        RG_PREFIX="rga --files-with-matches"
        local file
        file="$(
          FZF_DEFAULT_COMMAND="$RG_PREFIX '$1'" \
            fzf --sort --preview="[[ ! -z {} ]] && rga --pretty --context 5 {q} {}" \
              --phony -q "$1" \
              --bind "change:reload:$RG_PREFIX {q}" \
              --preview-window="70%:wrap"
        )" &&
        echo "opening $file" &&
        xdg-open "$file"
      }
    ''
in {
  programs.zsh = {
    enable = true;
    history.size = 10000;
    enableSyntaxHighlighting = true;
    initExtra = rga-fzf;
    oh-my-zsh = {
      enable = true;
      plugins = [ "git-prompt" "fzf" ];
      theme = "agnoster";
    };
  };
}