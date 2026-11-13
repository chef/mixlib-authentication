# Stop script execution when a non-terminating error occurs
$ErrorActionPreference = "Stop"
# This will run ruby test on windows platform

Write-Output "--- Ensuring GCC and Make are in the path"
$gccs = gci -path c:\ gcc.exe -Recurse -ErrorAction SilentlyContinue
$env:path = "$($gccs[0].DirectoryName)" + ";" + $env:path

$makes = gci -Path c:\ make.exe -Recurse -ErrorAction SilentlyContinue
$env:path = "$($makes[0].DirectoryName)" + ";" + $env:path


Write-Output "--- Install Bundler 2.6.9"
gem install bundler --version 2.6.9 --no-document
If ($lastexitcode -ne 0) { Exit $lastexitcode }

Write-Output "--- Install MSYS2 OpenSSL runtime"
ridk exec pacman -S --needed --noconfirm mingw-w64-ucrt-x86_64-openssl
If ($lastexitcode -ne 0) { Exit $lastexitcode }

Write-Output "--- Bundle install"

bundle _2.6.9_ config --local path vendor/bundle
If ($lastexitcode -ne 0) { Exit $lastexitcode }

bundle _2.6.9_ install --jobs=7 --retry=3
If ($lastexitcode -ne 0) { Exit $lastexitcode }

Write-Output "--- Install Fiddle 1.1.8 globally"
gem install fiddle --version 1.1.8 --no-document
If ($lastexitcode -ne 0) { Exit $lastexitcode }

Write-Output "--- Remove default fiddle gemspec"
ruby -e 'spec = Gem::Specification.find_all_by_name(:fiddle.to_s).find(&:default_gem?); File.delete(spec.loaded_from) if spec'
If ($lastexitcode -ne 0) { Exit $lastexitcode }

Write-Output "--- Bundle Execute"

bundle _2.6.9_ exec rake
If ($lastexitcode -ne 0) { Exit $lastexitcode }
