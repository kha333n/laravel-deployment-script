echo "Enter repo link"
read repo

echo "Cloning..."

git clone $repo

echo "Cloned"

# Extract the folder name from the repository URL
repo_name=$(basename $repo .git)


# Enable the dotglob option to include hidden files
shopt -s dotglob


## Move all files from the cloned folder to its parent directory
mv "$repo_name"/* .
mv "$repo_name"/.git* .

# Disable the dotglob option
shopt -u dotglob

#rm -rf "$repo_name"

echo "Moved to current folder"

# copy env
cp $repo_name/.env.example .env

# Install/update composer dependecies
composer install --no-interaction --prefer-dist --optimize-autoloader --no-dev

php artisan key:generate

echo "Run Migration? (Will override existing DB) (NOT RECOMMENDED) (Default No)"
run_migration="No"
read -r run_migration

if [ "$run_migration" != "No" ]; then
  # Run database migrations
  php artisan migrate --force --seed
fi

# Clear caches
php artisan cache:clear

# Clear expired password reset tokens
php artisan auth:clear-resets

# Clear and cache routes
php artisan route:cache

# Clear and cache config
php artisan config:cache

# Clear and cache views
php artisan view:cache

echo "Install node modules? (Default No)"
install_modules="No"
read -r install_modules

if [ "$install_modules" != "No" ]; then
  # Install node modules
  npm ci

  # Build assets using Laravel Mix
  npm run build
fi

php artisan storage:link


