# Claude Code

Claude Code stores login state, provider tokens, history, and local settings under
`~/.claude`. Keep those files mutable and keep API keys out of the Nix repository.

Home Manager copies `settings.template.json` to `~/.claude/settings.json` only
when that file does not already exist. Fill `ANTHROPIC_AUTH_TOKEN` in the copied
file after activation.
