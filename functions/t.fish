#  fish/functions/t.fish
function t --description "Tmux helper"
    set -l arg1 $argv[1]
    set -l session_name $argv[2]

    function _tmux_session_exists
        tmux has-session -t $argv[1] 2>/dev/null
    end

    switch "$arg1"
        case "kill"
            if test -z "$session_name"
                if set -q TMUX
                    set -l current_session (tmux display-message -p '#S')
                    echo "🪦 Killing current tmux session: **$current_session**"
                    tmux kill-session -t "$current_session"
                else
                    echo "⚠️ Not currently in a tmux session. Use 't kill <name>'."
                end
            else
                if _tmux_session_exists "$session_name"
                    echo "🪦 Killing tmux session: **$session_name**"
                    tmux kill-session -t "$session_name"
                else
                    echo "❌ Tmux session **$session_name** does not exist."
                    return 1
                end
            end

        case "exit"
            if set -q TMUX
                echo "🚪 Detaching from current session. It remains running."
                tmux detach
            else
                echo "⚠️ Not currently in a tmux session to exit."
                return 1
            end

        case "ls" ""
            tmux ls

        case "help"
            echo "Usage: t [session-name] (Auto-attach/Create)"
            echo "  or: t <command> [session-name]"
            echo ""
            echo "Commands:"
            echo "  <session-name>  Attach to **<session-name>**, creating it if it doesn't exist."
            echo "  kill [session]  Kill the named session, or the **current** one if no name is given."
            echo "  exit            **Detach** current session."
            echo "  ls              List all sessions."

        case "*"
            if test -n "$session_name"
                echo "❌ Error: Unknown command **$arg1**"
                return 1
            end

            if _tmux_session_exists "$arg1"
                echo "🔗 Attaching to existing tmux session: **$arg1**"
                tmux attach -t "$arg1"
            else
                echo "➕ Creating and attaching to new tmux session: **$arg1**"
                tmux new -s "$arg1"
            end
    end
end
