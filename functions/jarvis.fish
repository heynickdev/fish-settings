function jarvis --description "Jarvis talk back"
    if test (count $argv) -eq 0
        echo "Usage: jarvis <your prompt>"
        return 1
    end

    ~/.local/bin/jarvis $argv
end
