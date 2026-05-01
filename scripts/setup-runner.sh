#!/usr/bin/env bash
# ============================================================================
# Patirchi Self-Hosted GitHub Runner Setup
# ============================================================================
# Ushbu skript serverda GitHub Actions runner uchun barcha kerakli toollarni
# o'rnatadi: Java 17, Flutter SDK, Android SDK, command-line tools.
#
# Foydalanish:
#   1. Server'ga SSH qiling (Ubuntu 22.04+ tavsiya etiladi)
#   2. Yangi user yarating (xavfsizlik uchun root emas):
#        sudo adduser github-runner
#        sudo usermod -aG sudo github-runner
#        su - github-runner
#   3. Skriptni yuklang va ishga tushiring:
#        wget https://raw.githubusercontent.com/NozimjonDD/patirchi_mobile/mark/scripts/setup-runner.sh
#        chmod +x setup-runner.sh
#        ./setup-runner.sh
#   4. Runner'ni GitHub'da ro'yxatdan o'tkazing (skript oxirida instruksiya)
#
# Talablar:
#   - Ubuntu 22.04+ / Debian 12+
#   - 4 GB RAM minimum (8 GB tavsiya)
#   - 30 GB bo'sh joy (Flutter SDK + Android SDK + Gradle cache)
#   - Internet ulanishi
# ============================================================================

set -euo pipefail

readonly FLUTTER_VERSION="3.27.1"
readonly JAVA_VERSION="17"
readonly ANDROID_CMDLINE_TOOLS_VERSION="11076708"
readonly RUNNER_VERSION="2.321.0"

readonly INSTALL_ROOT="${HOME}/patirchi-ci"
readonly FLUTTER_HOME="${INSTALL_ROOT}/flutter"
readonly ANDROID_HOME="${INSTALL_ROOT}/android-sdk"
readonly RUNNER_HOME="${INSTALL_ROOT}/runner"

# ANSI ranglar
readonly C_GREEN='\033[0;32m'
readonly C_BLUE='\033[0;34m'
readonly C_YELLOW='\033[1;33m'
readonly C_RED='\033[0;31m'
readonly C_RESET='\033[0m'

log()   { echo -e "${C_BLUE}[$(date +%H:%M:%S)]${C_RESET} $*"; }
ok()    { echo -e "${C_GREEN}✓${C_RESET} $*"; }
warn()  { echo -e "${C_YELLOW}⚠${C_RESET} $*"; }
fail()  { echo -e "${C_RED}✗${C_RESET} $*" >&2; exit 1; }

# ----------------------------------------------------------------------------
# 0. Tizim talablari tekshirish
# ----------------------------------------------------------------------------
log "Tizim talablari tekshirilmoqda..."

[[ "$(uname -s)" == "Linux" ]] || fail "Bu skript faqat Linux uchun"
[[ "$EUID" -ne 0 ]] || fail "root sifatida ishga tushirmang. Yangi user yarating."

# Disk space (kamida 30 GB)
AVAIL_KB=$(df --output=avail "$HOME" | tail -1)
if (( AVAIL_KB < 30 * 1024 * 1024 )); then
    warn "30 GB dan kam bo'sh joy bor. Davom etish uchun Enter, bekor qilish uchun Ctrl+C"
    read -r
fi

mkdir -p "$INSTALL_ROOT"
ok "Install directory: $INSTALL_ROOT"

# ----------------------------------------------------------------------------
# 1. APT dependencies
# ----------------------------------------------------------------------------
log "APT paketlar yangilanmoqda..."
sudo apt-get update -qq
sudo apt-get install -y -qq \
    curl wget unzip git \
    ca-certificates apt-transport-https gnupg \
    libglu1-mesa \
    xz-utils \
    file \
    libstdc++6 \
    bash-completion \
    jq
ok "Asosiy paketlar o'rnatildi"

# ----------------------------------------------------------------------------
# 2. Java 17 (Temurin)
# ----------------------------------------------------------------------------
if ! command -v java &>/dev/null || ! java -version 2>&1 | grep -q "version \"${JAVA_VERSION}"; then
    log "Java ${JAVA_VERSION} (Temurin) o'rnatilmoqda..."
    wget -qO - https://packages.adoptium.net/artifactory/api/gpg/key/public | \
        sudo gpg --dearmor -o /usr/share/keyrings/adoptium.gpg
    echo "deb [signed-by=/usr/share/keyrings/adoptium.gpg] https://packages.adoptium.net/artifactory/deb $(lsb_release -cs) main" | \
        sudo tee /etc/apt/sources.list.d/adoptium.list >/dev/null
    sudo apt-get update -qq
    sudo apt-get install -y -qq "temurin-${JAVA_VERSION}-jdk"
    ok "Java o'rnatildi"
else
    ok "Java allaqachon o'rnatilgan"
fi

JAVA_HOME=$(dirname "$(dirname "$(readlink -f "$(which java)")")")
export JAVA_HOME

# ----------------------------------------------------------------------------
# 3. Flutter SDK
# ----------------------------------------------------------------------------
if [[ ! -d "$FLUTTER_HOME" ]]; then
    log "Flutter ${FLUTTER_VERSION} yuklab olinmoqda (~700 MB)..."
    cd "$INSTALL_ROOT"
    wget -q "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz" \
        -O flutter.tar.xz
    tar xf flutter.tar.xz
    rm flutter.tar.xz
    ok "Flutter o'rnatildi"
else
    ok "Flutter allaqachon o'rnatilgan"
fi

export PATH="${FLUTTER_HOME}/bin:${PATH}"

# Pre-cache Flutter (build paytida internet bo'lmasa ham ishlaydi)
log "Flutter cache yaratilmoqda..."
flutter --no-version-check precache --android --no-ios --no-linux --no-windows --no-macos --no-fuchsia --no-web 2>&1 | tail -3
ok "Flutter ready"

# ----------------------------------------------------------------------------
# 4. Android SDK (command-line tools + platform + build-tools)
# ----------------------------------------------------------------------------
if [[ ! -d "${ANDROID_HOME}/cmdline-tools/latest" ]]; then
    log "Android SDK command-line tools yuklab olinmoqda..."
    mkdir -p "${ANDROID_HOME}/cmdline-tools"
    cd "${ANDROID_HOME}/cmdline-tools"
    wget -q "https://dl.google.com/android/repository/commandlinetools-linux-${ANDROID_CMDLINE_TOOLS_VERSION}_latest.zip" \
        -O cmdline-tools.zip
    unzip -q cmdline-tools.zip
    mv cmdline-tools latest
    rm cmdline-tools.zip
    ok "Command-line tools o'rnatildi"
else
    ok "Android SDK cmdline-tools allaqachon mavjud"
fi

export ANDROID_HOME ANDROID_SDK_ROOT="${ANDROID_HOME}"
export PATH="${ANDROID_HOME}/cmdline-tools/latest/bin:${ANDROID_HOME}/platform-tools:${PATH}"

# Sdkmanager licenses
log "Android licenses qabul qilinmoqda..."
yes | sdkmanager --licenses >/dev/null 2>&1 || true

# Kerakli SDK komponentlari
log "Android SDK komponentlari o'rnatilmoqda..."
sdkmanager --install \
    "platform-tools" \
    "platforms;android-34" \
    "platforms;android-35" \
    "build-tools;34.0.0" \
    "build-tools;35.0.0" \
    "ndk;27.0.12077973" 2>&1 | tail -5
ok "Android SDK tayyor"

# ----------------------------------------------------------------------------
# 5. Environment vars (.bashrc / .profile)
# ----------------------------------------------------------------------------
log "Environment vars o'rnatilmoqda..."
ENV_FILE="${HOME}/.patirchi-ci-env"
cat > "$ENV_FILE" <<EOF
# Patirchi CI environment
export JAVA_HOME="${JAVA_HOME}"
export FLUTTER_HOME="${FLUTTER_HOME}"
export ANDROID_HOME="${ANDROID_HOME}"
export ANDROID_SDK_ROOT="${ANDROID_HOME}"
export PATH="\${FLUTTER_HOME}/bin:\${ANDROID_HOME}/cmdline-tools/latest/bin:\${ANDROID_HOME}/platform-tools:\${JAVA_HOME}/bin:\${PATH}"
EOF

# .bashrc ga source qilish
if ! grep -q "patirchi-ci-env" "${HOME}/.bashrc" 2>/dev/null; then
    echo "[ -f ${ENV_FILE} ] && source ${ENV_FILE}" >> "${HOME}/.bashrc"
fi
ok "Environment ${ENV_FILE} ga yozildi"

# ----------------------------------------------------------------------------
# 6. Flutter doctor
# ----------------------------------------------------------------------------
log "Flutter doctor ishga tushirilmoqda..."
flutter --no-version-check doctor || warn "Flutter doctor warnings bor (build uchun muhim emas bo'lishi mumkin)"

# ----------------------------------------------------------------------------
# 7. GitHub Actions runner
# ----------------------------------------------------------------------------
if [[ ! -d "$RUNNER_HOME" ]]; then
    log "GitHub Actions runner ${RUNNER_VERSION} yuklab olinmoqda..."
    mkdir -p "$RUNNER_HOME"
    cd "$RUNNER_HOME"
    ARCH="x64"
    if [[ "$(uname -m)" == "aarch64" ]] || [[ "$(uname -m)" == "arm64" ]]; then
        ARCH="arm64"
    fi
    wget -q "https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-${ARCH}-${RUNNER_VERSION}.tar.gz" \
        -O runner.tar.gz
    tar xzf runner.tar.gz
    rm runner.tar.gz
    ok "Runner binary o'rnatildi"
else
    ok "Runner allaqachon mavjud"
fi

# ----------------------------------------------------------------------------
# 8. Yakuniy ko'rsatmalar
# ----------------------------------------------------------------------------
echo ""
echo "============================================================================"
echo -e "${C_GREEN}✓ Setup tugadi!${C_RESET}"
echo "============================================================================"
echo ""
echo "Endi runner'ni GitHub'da ro'yxatdan o'tkazing:"
echo ""
echo -e "${C_YELLOW}1.${C_RESET} GitHub'da bu URL'ga kiring:"
echo "   https://github.com/NozimjonDD/patirchi_mobile/settings/actions/runners/new"
echo ""
echo -e "${C_YELLOW}2.${C_RESET} 'Linux' tanlang, 'x64' (yoki 'arm64') tanlang"
echo ""
echo -e "${C_YELLOW}3.${C_RESET} Quyidagi buyruqlarni nusxalang va serverda ishga tushiring:"
echo ""
echo "   cd $RUNNER_HOME"
echo "   ./config.sh \\"
echo "       --url https://github.com/NozimjonDD/patirchi_mobile \\"
echo "       --token YOUR_TOKEN_FROM_GITHUB \\"
echo "       --name patirchi-builder \\"
echo "       --labels 'patirchi-builder,linux' \\"
echo "       --work _work \\"
echo "       --unattended"
echo ""
echo -e "${C_YELLOW}4.${C_RESET} Runner'ni systemd service sifatida ishga tushiring:"
echo ""
echo "   sudo $RUNNER_HOME/svc.sh install $USER"
echo "   sudo $RUNNER_HOME/svc.sh start"
echo "   sudo $RUNNER_HOME/svc.sh status"
echo ""
echo -e "${C_YELLOW}5.${C_RESET} GitHub Secrets'ga quyidagilarni qo'shing:"
echo "   • TELEGRAM_BOT_TOKEN     — bot token"
echo "   • TELEGRAM_BUILD_CHAT_ID — APK yuboriladigan chat ID"
echo "   • ANDROID_KEYSTORE_BASE64"
echo "   • ANDROID_KEYSTORE_PASSWORD"
echo "   • ANDROID_KEY_PASSWORD"
echo "   • ANDROID_KEY_ALIAS"
echo ""
echo -e "${C_YELLOW}6.${C_RESET} Test qiling: GitHub Actions tab → Run workflow"
echo ""
echo "============================================================================"
echo "Environment vars: source ${ENV_FILE}"
echo "Yangi shell ochilganda avtomatik yuklanadi (.bashrc'ga qo'shilgan)"
echo "============================================================================"
