#  fish/functions/create.fish
function create
    set -l opt $argv[1]
    set -l project_name (basename (pwd))

    switch "$opt"
        case all
            create_env
            create_air_config
            create_editorconfig
            create_prettierrc
            create_gitignore "$project_name"
            create_docker_compose
            create_sqlc_config
            create_justfile
        case air
            create_air_config
        case style
            create_editorconfig
            create_prettierrc
            create_gitignore "$project_name"
        case env
            create_env
        case editor
            create_editorconfig
        case pretty
            create_prettierrc
        case ignore
            create_gitignore "$project_name"
        case make
            create_makefile
        case docker
            create_docker_compose
        case sqlc
            create_sqlc_config
        case django
            create_djlintrc
        case just
            create_justfile
        case "*"
            echo "Usage: create <all | air | style | env | make | docker | sqlc | django | just>"
    end
end

# --- Sub-helpers ---

function create_air_config
    if test -f .air.toml
        echo "⚠️ .air.toml exists"
        return 1
    end
    printf 'root = "."\ntmp_dir = "tmp"\n\n[build]\ncmd = "templ generate && go build -o ./tmp/main ./cmd/main.go"\nbin = "./tmp/main"\ninclude_ext = ["go", "templ", "html"]\nexclude_dir = ["assets", "tmp", "vendor", "node_modules"]\nexclude_regex = ["_templ\\\\.go", "_test\\\\.go"]\nstop_on_error = true\nsend_interrupt = true\ndelay = 100\n\n[log]\ntime = true\nmain_only = false\n\n[misc]\nclean_on_exit = true\n\n[screen]\nclear_on_rebuild = true\n' >.air.toml
    echo "✅ Created .air.toml"
end

function create_gitignore
    if test -f .gitignore
        echo "⚠️ .gitignore exists"
        return 1
    end
    set -l name (test -n "$argv[1]"; and echo $argv[1]; or echo (basename (pwd)))
    printf "# Go\n/$name\n*.exe\n*.test\n/tmp/\n*_templ.go\n\n# Secrets\n.env\n*.log\n\n# Web\n/node_modules/\n/vendor/\n/dist/\n" >.gitignore
    echo "✅ Created .gitignore"
end

function create_editorconfig
    if test -f .editorconfig
        echo "⚠️ .editorconfig exists"
        return 1
    end
    printf "root = true\n\n[*]\nindent_style = space\nindent_size = 2\nend_of_line = lf\ncharset = utf-8\n\n[*.go]\nindent_style = space\nindent_size = 2\n\n[Makefile]\nindent_style = tab\n" >.editorconfig
    echo "✅ Created .editorconfig"
end

function create_prettierrc
    if test -f .prettierrc
        echo "⚠️ .prettierrc exists"
        return 1
    end
    printf "{\n  \"semi\": false,\n  \"singleQuote\": true,\n  \"useTabs\": false,\n  \"tabWidth\": 2,\n  \"bracketSameLine\": true,\n  \"printWidth\": 100\n}\n" >.prettierrc
    echo "✅ Created .prettierrc"
end

function create_env
    if test -f .env
        echo "⚠️ .env exists"
        return 1
    end
    set -l d_name (basename (pwd))
    printf "APP_ENV=dev\nHTTP_LISTEN_ADDR=:42069\nPOSTGRES_USER=dev\nPOSTGRES_PASSWORD=devArea\nPOSTGRES_DB=$d_name\n\nDB_URL=\"postgres://dev:devArea@localhost:5432/$d_name?sslmode=disable\"\n" >.env
    echo "✅ Created .env"
end

function create_docker_compose
    if test -f docker-compose.yml
        echo "⚠️ docker-compose exists"
        return 1
    end
    set -l d_name (basename (pwd))
    printf "services:\n  postgres:\n    image: postgres:16\n    container_name: $d_name\n    restart: unless-stopped\n    env_file:\n      - .env\n    ports:\n      - \"5432:5432\"\n    volumes:\n      - pgdata:/var/lib/postgresql/data\n\nvolumes:\n  pgdata:\n" >docker-compose.yml
    echo "✅ Created docker-compose.yml"
end

function create_sqlc_config
    if test -f sqlc.yaml
        echo "⚠️ sqlc.yaml exists"
        return 1
    end
    mkdir -p sql/schema sql/queries internal/database
    printf "version: \"2\"\nsql:\n  - schema: \"sql/schema\"\n    queries: \"sql/queries\"\n    engine: \"postgresql\"\n    gen:\n      go:\n        out: \"internal/database\"\n        package: \"database\"\n" >sqlc.yaml
    echo "✅ Created sqlc.yaml"
end

function create_djlintrc
    if test -f .djlintrc
        echo "⚠️ .djlintrc exists"
        return 1
    end
    printf "{\n    \"profile\": \"django\",\n    \"indent\": 2,\n    \"max_line_length\": 120\n}\n" >.djlintrc
    echo "✅ Created .djlintrc"
end

function create_justfile
    if test -f justfile
        echo "⚠️ justfile exists"
        return 1
    end
    mkdir -p ./internal/app/assets/css
    if not test -f ./internal/app/assets/css/input.css
        printf "@import 'tailwindcss';\n" >./internal/app/assets/css/input.css
    end
    printf "set dotenv-load := true\ngobin := `go env GOPATH` / \"bin\"\n\ntempl:\n    templ generate --proxy=\"http://localhost:42069\" --open-browser=false --proxyport=\"8080\" --watch\n\nserver:\n    {{gobin}}/air\n\ntailwind:\n    tailwindcss -i ./internal/app/assets/css/input.css -o ./internal/app/assets/css/styles.css --watch\n\n[parallel]\ndev: tailwind templ server\n" >justfile
    echo "✅ Created justfile"
end

function create_makefile
    if test -f Makefile
        echo "⚠️ Makefile exists"
        return 1
    end
    printf "GOBIN := \$(shell go env GOPATH)/bin\n\ntempl:\n\ttempl generate --proxy=\"http://localhost:42069\" --open-browser=false --proxyport=\"8080\" --watch\n\nserver:\n\t\$(GOBIN)/air\n\ndev:\n\tmake -j3 templ server\n" >Makefile
    echo "✅ Created Makefile"
end
