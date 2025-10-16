# $WARP_IS_LOCAL_SHELL_SESSION can be used to check if it's the warp terminal

# comes from func warp_title
export INSIDE_EMACS=
if (( $+functions[warp_update_prompt_vars] )); then
  # Save the original function
  functions[_warp_update_prompt_vars_orig]=$functions[warp_update_prompt_vars]

  # Replace with a wrapper that temporarily disables nounset
  function warp_update_prompt_vars() {
    emulate -L zsh
    setopt local_options
    unsetopt nounset
    _warp_update_prompt_vars_orig "$@"
  }
fi

if (( $+functions[warp_precmd] )); then
  # Save the original function
  functions[_warp_precmd_orig]=$functions[warp_precmd]

  # Replace with a wrapper that temporarily disables nounset
  function warp_precmd() {
    emulate -L zsh
    setopt local_options
    unsetopt nounset
    _warp_precmd_orig "$@"
  }
fi
