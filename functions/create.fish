# --- STANDALONE CREATE WRAPPER ---

function create --description "Independent config creator"
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
    case docker
      create_docker_compose
    case sqlc
      create_sqlc_config
    case just
      create_justfile
    case make
      create_makefile
    case django
      create_djlintrc
    case "*"
      echo "Usage: create <all | air | style | env | docker | sqlc | just | make | django>"
  end
end

# --- SUB-HELPERS (Configuration Generators) ---

function create_air_config
  if test -f .air.toml
    echo "⚠️ .air.toml exists"
    return 1
  end
  echo 'root = "."
tmp_dir = "tmp"

[build]
cmd = "go build -o ./tmp/main ./cmd/main.go"
bin = "./tmp/main"
include_ext = ["go", "html"]
exclude_dir = ["assets", "tmp", "vendor", "node_modules", "internal/app/assets/css"]
exclude_regex = ["_test\\\\.go"]
stop_on_error = true
send_interrupt = true
delay = 1000

[color]
app = ""
build = "yellow"
main = "magenta"
runner = "green"
watcher = "cyan"

[log]
time = true
main_only = false

[misc]
clean_on_exit = true

[screen]
clear_on_rebuild = true' > .air.toml
  echo "✅ Created .air.toml"
end

function create_gitignore
  if test -f .gitignore
    echo "⚠️ .gitignore exists"
    return 1
  end
  set -l name (test -n "$argv[1]"; and echo $argv[1]; or echo (basename (pwd)))
  echo "# Go
/$name
bin/
*.exe
*.test
/tmp/
*_templ.go

# Secrets
.env
*.log

# Web
/node_modules/
/vendor/
/dist/" > .gitignore
  echo "✅ Created .gitignore"
end

function create_editorconfig
  if test -f .editorconfig
    echo "⚠️ .editorconfig exists"
    return 1
  end
  echo 'root = true

[*]
indent_style = space
indent_size = 2
end_of_line = lf
charset = utf-8

[*.go]
indent_style = tab
indent_size = 4

[Makefile]
indent_style = tab' > .editorconfig
  echo "✅ Created .editorconfig"
end

function create_prettierrc
  if test -f .prettierrc
    echo "⚠️ .prettierrc exists"
    return 1
  end
  echo '{
  "semi": false,
  "singleQuote": true,
  "useTabs": false,
  "tabWidth": 2,
  "bracketSameLine": true,
  "printWidth": 100
}' > .prettierrc
  echo "✅ Created .prettierrc"
end

function create_env
  if test -f .env
    echo "⚠️ .env exists"
    return 1
  end
  set -l d_name (basename (pwd))
  echo "APP_ENV=dev
HTTP_LISTEN_ADDR=:42069

POSTGRES_USER=dev
POSTGRES_PASSWORD=devArea
POSTGRES_DB=$d_name
DB_URL=\"postgres://dev:devArea@localhost:5432/$d_name?sslmode=disable\"

REDIS_PASSWORD=devArea
REDIS_URL=\"redis://:devArea@localhost:6379/0\"" > .env
  echo "✅ Created .env"
end

function create_docker_compose
  if test -f docker-compose.yml
    echo "⚠️ docker-compose exists"
    return 1
  end
  set -l d_name (basename (pwd))
  echo "services:
  postgres:
    image: postgres:16
    container_name: $d_name-postgres
    restart: unless-stopped
    env_file:
      - .env
    ports:
      - \"5432:5432\"
    volumes:
      - pgdata:/var/lib/postgresql/data

  redis:
    image: redis:7-alpine
    container_name: $d_name-redis
    restart: unless-stopped
    command: redis-server --requirepass \${REDIS_PASSWORD}
    env_file:
      - .env
    ports:
      - \"6379:6379\"
    volumes:
      - redisdata:/data

volumes:
  pgdata:
  redisdata:" > docker-compose.yml
  echo "✅ Created docker-compose.yml"
end

function create_sqlc_config
  if test -f sqlc.yaml
    echo "⚠️ sqlc.yaml exists"
    return 1
  end
  mkdir -p db/migrations db/schema internal/database
  echo 'version: "2"
sql:
  - schema: "db/migrations"
    queries: "db/schema"
    engine: "postgresql"
    gen:
      go:
        out: "internal/database"
        package: "database"
        emit_json_tags: true
        emit_empty_slices: true
        emit_interface: true
        overrides:
          - db_type: "uuid"
            go_type: "github.com/google/uuid.UUID"
          - db_type: "timestamptz"
            go_type: "time.Time"' > sqlc.yaml
  echo "✅ Created sqlc.yaml"
end

function create_justfile
  if test -f justfile
    echo "⚠️ justfile exists"
    return 1
  end
  mkdir -p ./internal/app/assets/css
  if not test -f ./internal/app/assets/css/input.css
    echo "@import 'tailwindcss';" > ./internal/app/assets/css/input.css
  end
  echo 'set dotenv-load := true
gobin := `go env GOPATH` / "bin"

templ:
	templ generate --proxy="http://localhost:42069" --open-browser=false --proxyport="8080" --watch

server:
	{{gobin}}/air

migrate:
	goose -dir db/migrations postgres "${DB_URL}" up

down:
	goose -dir db/migrations postgres "${DB_URL}" down

tailwind:
	tailwindcss -i ./internal/app/assets/css/input.css -o ./internal/app/assets/css/styles.css --watch

[parallel]
dev: tailwind templ server' > justfile
  echo "✅ Created justfile"
end

function create_djlintrc
  if test -f .djlintrc
    echo "⚠️ .djlintrc exists"
    return 1
  end
  printf "{\n    \"profile\": \"django\",\n    \"indent\": 2,\n    \"max_line_length\": 120\n}\n" > .djlintrc
  echo "✅ Created .djlintrc"
end

function create_makefile
  if test -f Makefile
    echo "⚠️ Makefile exists"
    return 1
  end
  printf "GOBIN := \$(shell go env GOPATH)/bin\n\ntempl:\n\ttempl generate --proxy=\"http://localhost:42069\" --open-browser=false --proxyport=\"8080\" --watch\n\nserver:\n\t\$(GOBIN)/air\n\ndev:\n\tmake -j3 templ server\n" > Makefile
  echo "✅ Created Makefile"
end
