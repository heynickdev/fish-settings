# --- MAIN PROJECT CREATOR ---

function mk --description "Project Creation Tool"
  # Dynamically source create.fish so the helper functions are available
  source (status dirname)/create.fish

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
      echo "🚀 Initializing Go + Templ + Tailwind + Docker + SQLC + Redis environment..."

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
  \"github.com/redis/go-redis/v9\"
)

type APIConfig struct {
  DB    database.Querier
  Redis *redis.Client
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
  \"context\"
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
  \"github.com/redis/go-redis/v9\"
)

func main() {
  if err := godotenv.Load(); err != nil {
    fmt.Println(\"Warning: .env file not found\")
  }

  // Database Connection
  dbURL := os.Getenv(\"DB_URL\")
  if dbURL != \"\" {
    db, err := sql.Open(\"postgres\", dbURL)
    if err != nil {
      fmt.Println(\"Error preparing database connection: \", err)
    }
    defer db.Close()
  }

  // Redis Connection
  redisURL := os.Getenv(\"REDIS_URL\")
  if redisURL != \"\" {
    opt, err := redis.ParseURL(redisURL)
    if err != nil {
      fmt.Println(\"Error parsing Redis URL: \", err)
    } else {
      rdb := redis.NewClient(opt)
      defer rdb.Close()
      if err := rdb.Ping(context.Background()).Err(); err != nil {
        fmt.Println(\"Error connecting to Redis: \", err)
      } else {
        fmt.Println(\"Connected to Redis successfully\")
      }
    }
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
      go get github.com/go-chi/chi/v5 github.com/joho/godotenv github.com/lib/pq github.com/a-h/templ github.com/redis/go-redis/v9 github.com/google/uuid
      go mod tidy

      echo "🛠️ Initial Code Generation..."
      if command -v templ >/dev/null
        templ generate
      end
      if command -v sqlc >/dev/null
        sqlc generate
      end

      git add .
      git commit -m "Initial commit: Go/Templ/Tailwind/Docker/SQLC/Redis setup"
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
