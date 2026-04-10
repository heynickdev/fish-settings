function mc --description 'Start a Minecraft server with specified RAM'
    # Check if exactly 3 arguments are provided
    if test (count $argv) -ne 3
        echo "Usage: mc <jar_name> <min_ram_gb> <max_ram_gb>"
        echo "Example: mc paper-1.21.11-128 2 8"
        return 1
    end

    # Assign arguments to local variables for clarity
    set -l jar_base $argv[1]
    set -l min_ram  $argv[2]
    set -l max_ram  $argv[3]
    set -l jar_file "$jar_base.jar"

    # Security/Robustness: Check if the jar file actually exists
    if not test -f "$jar_file"
        echo " Error: The file '$jar_file' was not found in the current directory."
        return 1
    end

    # Security/Robustness: Check if RAM inputs are numeric
    if not string match -qr '^[0-9]+$' "$min_ram"
       or not string match -qr '^[0-9]+$' "$max_ram"
        echo " Error: RAM values must be integers (GB)."
        return 1
    end

    echo "Launching $jar_file with ${min_ram}GB min and ${max_ram}GB max RAM..."

    # Execution: Use nogui to prevent unnecessary GUI overhead
    java -Xms"$min_ram"G -Xmx"$max_ram"G -jar "$jar_file" nogui
end
