# --- SUB-HELPERS (Configuration Generators) ---

function create_air_config
  if test -f .air.toml
    echo "⚠️ .air.toml exists"
    return 1
  end
  echo 'root = "."
tmp_dir = "tmp"

[build]
cmd = "templ generate && go build -o ./tmp/main ./cmd/main.go"
bin = "./tmp/main"
include_ext = ["go", "templ", "html"]
exclude_dir = ["assets", "tmp", "vendor", "node_modules"]
exclude_regex = ["_templ\\.go", "_test\\.go"]
stop_on_error = true
send_interrupt = true
delay = 100

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

DB_URL=\"postgres://dev:devArea@localhost:5432/$d_name?sslmode=disable\"" > .env
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
    container_name: $d_name
    restart: unless-stopped
    env_file:
      - .env
    ports:
      - \"5432:5432\"
    volumes:
      - pgdata:/var/lib/postgresql/data

volumes:
  pgdata:" > docker-compose.yml
  echo "✅ Created docker-compose.yml"
end

function create_sqlc_config
  if test -f sqlc.yaml
    echo "⚠️ sqlc.yaml exists"
    return 1
  end
  mkdir -p sql/schema sql/queries internal/database
  echo 'version: "2"
sql:
  - schema: "sql/schema"
    queries: "sql/queries"
    engine: "postgresql"
    gen:
      go:
        out: "internal/database"
        package: "database"' > sqlc.yaml
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
  goose -dir sql/schema postgres "${DB_URL}" up

down:
  goose -dir sql/schema postgres "${DB_URL}" down

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

# --- MAIN PROJECT CREATOR ---

function mk --description "Project Creation Tool"
  set -l dir_name $argv[1]
  set -l init_cmd $argv[2]
  set -l type_cmd $argv[3]

  if test -z "$dir_name"
    echo "Usage: mk <dir-name> init [go | django]"
    return 1
  end

  mkdir -p "$dir_name"; and cd "$dir_name"
  echo "📁 Created and entered "(pwd)

  if test "$init_cmd" = init
    git init

    create_editorconfig
    create_prettierrc
    create_gitignore "$dir_name"

    if test "$type_cmd" = go
      echo "🚀 Initializing Go + Templ + Tailwind + Docker + SQLC environment..."

      create_env
      create_docker_compose
      create_sqlc_config
      create_air_config

      go mod init "$dir_name"

      # Generate architecture
      mkdir -p internal/api
      echo "package api

import (
  \"$dir_name/internal/database\"
)

type APIConfig struct {
  DB *database.Queries
}" > internal/api/api.go

      mkdir -p internal/app
      echo 'package app

import (
  "fmt"
  "net/http"
  "github.com/a-h/templ"
)

func Render(comp templ.Component) http.HandlerFunc {
  return func(w http.ResponseWriter, r *http.Request) {
    w.Header().Set("Content-Type", "text/html; charset=utf-8")
    if err := comp.Render(r.Context(), w); err != nil {
      http.Error(w, "Internal Server Error", http.StatusInternalServerError)
    }
  }
}

func Static(folder string) http.Handler {
  return http.StripPrefix(fmt.Sprintf("/%v/", folder), http.FileServer(http.Dir(fmt.Sprint("./internal/app/assets/", folder))))
}' > internal/app/app.go

      echo 'package app

templ layout(title string) {
  <!DOCTYPE html>
  <html lang="en">
    <head>
      <meta charset="UTF-8"/>
      <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
      <title>{ title }</title>
      <link rel="stylesheet" href="/css/styles.css"/>
      <script src="https://unpkg.com/htmx.org@1.9.10"></script>
      <script src="https://kit.fontawesome.com/8c654ed165.js" crossorigin="anonymous"></script>
      <script defer src="https://cdn.jsdelivr.net/npm/alpinejs@3.x.x/dist/cdn.min.js"></script>
    </head>
    <body class="bg-slate-900 text-white antialiased">
      { children... }
    </body>
  </html>
}' > internal/app/layout.templ

      echo 'package app

templ Home() {
  @layout("Home Page") {
    <div class="flex flex-col items-center justify-center h-screen">
      <h1 class="text-4xl font-bold mb-4">Hello from Templ!</h1>
      <i class="fa-solid fa-mountain-sun text-6xl text-blue-500"></i>
    </div>
  }
}' > internal/app/home.templ

      mkdir -p cmd
      echo "package main

import (
  \"$dir_name/internal/app\"
  \"database/sql\"
  \"fmt\"
  \"log\"
  \"net/http\"
  \"os\"
  \"time\"

  \"github.com/go-chi/chi/v5\"
  \"github.com/go-chi/chi/v5/middleware\"
  \"github.com/joho/godotenv\"
  _ \"github.com/lib/pq\"
)

func main() {
  if err := godotenv.Load(); err != nil {
    fmt.Println(\"Warning: .env file not found\")
  }

  dbURL := os.Getenv(\"DB_URL\")
  if dbURL != \"\" {
    db, err := sql.Open(\"postgres\", dbURL)
    if err != nil {
      fmt.Println(\"Error preparing database connection: \", err)
    }
    defer db.Close()
  }

  r := chi.NewRouter()
  r.Use(middleware.RequestID)
  r.Use(middleware.RealIP)
  r.Use(middleware.Logger)
  r.Use(middleware.Recoverer)
  r.Use(middleware.Timeout(60 * time.Second))

  r.Handle(\"/css/*\", app.Static(\"css\"))
  r.Get(\"/\", app.Render(app.Home()))

  port := os.Getenv(\"HTTP_LISTEN_ADDR\")
  if port == \"\" {
    port = \":42069\"
  }

  fmt.Println(\"------------------------------------------------\")
  fmt.Printf(\" Backend listening on %s\\n\", port)
  fmt.Println(\" Visit http://localhost:8080 for live reload\")
  fmt.Println(\"------------------------------------------------\")

  if err := http.ListenAndServe(port, r); err != nil {
    log.Fatal(err)
  }
}" > cmd/main.go

      create_justfile

      echo "📦 Downloading dependencies..."
      go get github.com/go-chi/chi/v5 github.com/joho/godotenv github.com/lib/pq github.com/a-h/templ
      go mod tidy

      echo "🛠️ Initial Code Generation..."
      if command -v templ >/dev/null
        templ generate
      end
      if command -v sqlc >/dev/null
        sqlc generate
      end

      pnpm add tailwindcss @tailwindcss/cli

      git add .
      git commit -m "Initial commit: Go/Templ/Tailwind/Docker/SQLC setup"
      git branch -M main

    else if test "$type_cmd" = django
      echo "🚀 Initializing Django environment..."
      
      create_djlintrc

      git add .
      git commit -m "Initial commit: Django setup"
      git branch -M main
      
    else
      git add .
      git commit -m "Initial commit"
      git branch -M main
    end
  end
end
