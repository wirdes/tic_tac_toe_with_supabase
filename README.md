# Tic-Tac-Toe

This is a simple online tic-tac-toe game that uses Supabase as the backend. It is built with Flutter and Dart.

## Getting Started

### Supabase Setup

#### Tables

- Create a new project on [Supabase](https://supabase.com/).
- Create a 'profiles' table with the following columns:
  </br><img src="https://supa.merterim.dev/storage/v1/object/public/github/profiles_table.png" alt="Örnek Resim" width="300" height="200">
- Create a 'game_rooms' table with the following columns:
  </br><img src="https://supa.merterim.dev/storage/v1/object/public/github/game_rooms_table.png" alt="Örnek Resim" width="300" height="200">
- Create a 'game_moves' table with the following columns:
  </br><img src="https://supa.merterim.dev/storage/v1/object/public/github/game_moves_table.png" alt="Örnek Resim" width="300" height="200">
- Create a 'player_rooms' table with the following columns:
  </br><img src="https://supa.merterim.dev/storage/v1/object/public/github/player_room_table.png?t=2024-08-15T00%3A35%3A42.573Z" alt="Örnek Resim" width="300" height="200">

#### Functions

- Create a new function for when users anonymously sign in at username to the profiles table
  </br><img src="https://supa.merterim.dev/storage/v1/object/public/github/new_user_func.png" alt="Örnek Resim" width="300" height="200">

#### Policies

- Every table should have a policy that allows users
    * Game Rooms:
        - Select
        - Insert
        - Update
        - All
    * Game Moves:
        - Select
        - Insert
        - Delete
        - All
    * Player Rooms:
        - Select
        - Insert
        - All
    * Profiles:
        - Select
        - Insert
        - Update
    
These policies should ensure that auth users can access them, as shown in the images below.

  </br><img src="https://supa.merterim.dev/storage/v1/object/public/github/policy.png" alt="Örnek Resim" width="300" height="200">

### Flutter Setup

- Clone the repository
- Run `flutter pub get`
- Create a `config.json` file in the root directory and add the following:
  ```JSON
  {
    "URL": "your_supabase_url",
    "API_KEY": "your_supabase_anon_key"
  }
    ```

- Replace `your_supabase_url` and `your_supabase_anon_key` with your Supabase URL and anon key
- Run the app with run.sh file or `flutter run --dart-define-from-file=config.json`













