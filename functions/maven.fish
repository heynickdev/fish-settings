function maven --description "Friendly Maven command shortcuts"
    if test (count $argv) -eq 0
        __maven_help
        return 0
    end

    # Prefer the project's Maven Wrapper when one exists.
    set -l mvn_command mvn

    if test -x ./mvnw
        set mvn_command ./mvnw
    end

    set -l subcommand $argv[1]

    switch $subcommand
        case create new
            set -l artifact_id $argv[2]
            set -l group_id com.nick

            if test -z "$artifact_id"
                echo "Usage: maven create <artifact-id> [group-id]"
                echo
                echo "Examples:"
                echo "  maven create hello-world"
                echo "  maven create garage-api com.heynickdev"
                return 1
            end

            if test (count $argv) -ge 3
                set group_id $argv[3]
            end

            echo "Creating Maven project"
            echo "  Artifact ID: $artifact_id"
            echo "  Group ID:    $group_id"
            echo

            $mvn_command archetype:generate \
                -DgroupId="$group_id" \
                -DartifactId="$artifact_id" \
                -DarchetypeArtifactId=maven-archetype-quickstart \
                -DarchetypeVersion=1.5 \
                -DinteractiveMode=false

        case clean
            $mvn_command clean $argv[2..-1]

        case compile build
            $mvn_command compile $argv[2..-1]

        case test
            $mvn_command test $argv[2..-1]

        case package pack
            $mvn_command package $argv[2..-1]

        case verify
            $mvn_command verify $argv[2..-1]

        case install
            $mvn_command install $argv[2..-1]

        case run
            set -l main_class $argv[2]

            if test -z "$main_class"
                echo "Usage: maven run <fully-qualified-main-class> [arguments]"
                echo
                echo "Example:"
                echo "  maven run com.nick.App"
                return 1
            end

            set -l application_arguments

            if test (count $argv) -ge 3
                set application_arguments (string join " " $argv[3..-1])
            end

            if test -n "$application_arguments"
                $mvn_command exec:java \
                    -Dexec.mainClass="$main_class" \
                    -Dexec.args="$application_arguments"
            else
                $mvn_command exec:java \
                    -Dexec.mainClass="$main_class"
            end

        case tree dependency-tree
            $mvn_command dependency:tree $argv[2..-1]

        case dependencies deps
            $mvn_command dependency:list $argv[2..-1]

        case wrapper
            $mvn_command wrapper:wrapper $argv[2..-1]

        case version
            $mvn_command --version

        case mvn raw
            if test (count $argv) -lt 2
                echo "Usage: maven mvn <arguments>"
                echo
                echo "Example:"
                echo "  maven mvn clean package -DskipTests"
                return 1
            end

            $mvn_command $argv[2..-1]

        case help --help -h
            __maven_help

        case '*'
            # Unknown commands are passed directly to Maven.
            #
            # Example:
            #   maven dependency:analyze
            $mvn_command $argv
    end
end

function __maven_help
    echo "Friendly Maven commands"
    echo
    echo "Project creation:"
    echo "  maven create <name> [group-id]  Create a Java project"
    echo
    echo "Build lifecycle:"
    echo "  maven clean                     Remove build output"
    echo "  maven compile                   Compile the project"
    echo "  maven test                      Run tests"
    echo "  maven package                   Build the JAR or WAR"
    echo "  maven verify                    Run verification checks"
    echo "  maven install                   Install into the local repository"
    echo
    echo "Development:"
    echo "  maven run <main-class> [args]   Run a Java main class"
    echo "  maven tree                      Show the dependency tree"
    echo "  maven dependencies              List dependencies"
    echo "  maven wrapper                   Generate Maven Wrapper files"
    echo
    echo "Utilities:"
    echo "  maven version                   Show the Maven version"
    echo "  maven mvn <arguments>           Run a raw Maven command"
    echo "  maven help                      Show this help"
    echo
    echo "Unknown commands are passed directly to Maven:"
    echo "  maven clean package -DskipTests"
end
