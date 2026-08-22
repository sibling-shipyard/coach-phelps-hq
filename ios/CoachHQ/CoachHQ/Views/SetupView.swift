import SwiftUI

/// Native equivalent of Setup.tsx's wizard. Shown when pendingSetupLogin is set — signed in
/// but setup not complete. Checks two conditions directly against GitHub's API so returning
/// users aren't blocked by an expired server session:
///   Step 1 — does `coach-<login>` repo exist?
///   Step 2 — does the coach-phelps App have access to it?
/// When both pass, sign-in is re-run automatically to re-establish the server session.
struct SetupView: View {
    let login: String
    @EnvironmentObject var authManager: GitHubAuthManager
    @AppStorage(UserFacingError.devModeKey) private var devModeEnabled = false

    @State private var repoStepComplete = false
    @State private var installStepComplete = false
    @State private var isChecking = true
    @State private var isInstalling = false
    @State private var isAutoAdvancing = false
    @State private var errorMessage: String?

    private var generateURL: URL? {
        var components = URLComponents(string: "https://github.com/new")!
        components.queryItems = [
            URLQueryItem(name: "template_owner", value: "sibling-shipyard"),
            URLQueryItem(name: "template_name", value: "coach-skeleton"),
            URLQueryItem(name: "owner", value: login),
            URLQueryItem(name: "name", value: "coach-\(login)"),
            URLQueryItem(name: "visibility", value: "private"),
        ]
        return components.url
    }

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                if repoStepComplete {
                    step2Content
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                } else {
                    step1Content
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .animation(PremiumMotion.state, value: repoStepComplete)

            actionSection
                .padding(.horizontal, 24)
                .safeAreaPadding(.bottom, 12)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(WarmInstrument.desk.ignoresSafeArea())
        .overlay(alignment: .topTrailing) {
            Button {
                Haptics.tap()
                authManager.signOut()
            } label: {
                Text("Cancel")
                    .font(WarmInstrument.monoLabel(10.5))
                    .tracking(0.8)
                    .foregroundColor(WarmInstrument.inkMuted)
            }
            .padding(.horizontal, 24)
            .padding(.top, 12)
        }
        .task(id: login) {
            await refreshSetupStatus()
        }
    }

    // MARK: - Step content

    private var step1Content: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Wiring up your\nGitHub repo.")
                .font(WarmInstrument.coachVoice(30))
                .foregroundColor(WarmInstrument.ink)
                .fixedSize(horizontal: false, vertical: true)
                .onboardingReveal(index: 0)
                .padding(.bottom, 28)

            VStack(alignment: .leading, spacing: 14) {
                stepBullet("Create your training log once")
                stepBullet("All your workouts in one private place")
                stepBullet("Coach reads it, you never re-explain")
            }
            .onboardingReveal(index: 1)

            if isChecking {
                ProgressView()
                    .scaleEffect(0.65)
                    .tint(WarmInstrument.inkMuted)
                    .padding(.top, 24)
                    .onboardingReveal(index: 2)
            }
        }
        .padding(.horizontal, 32)
    }

    private var step2Content: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Connect Coach\nto your repo.")
                .font(WarmInstrument.coachVoice(30))
                .foregroundColor(WarmInstrument.ink)
                .fixedSize(horizontal: false, vertical: true)
                .onboardingReveal(index: 0)
                .padding(.bottom, 28)

            if isChecking || isAutoAdvancing {
                // Checking installation or auto-advancing — show spinner instead of instructions
                ProgressView()
                    .scaleEffect(0.65)
                    .tint(WarmInstrument.inkMuted)
                    .onboardingReveal(index: 1)
            } else {
                VStack(alignment: .leading, spacing: 18) {
                    numberedStep(1,
                        prefix: "When GitHub asks which repositories to share, choose ",
                        bold: "Only select repositories",
                        suffix: ".")
                    numberedStep(2,
                        prefix: "Pick ",
                        bold: "coach-\(login)",
                        suffix: ". Don't grant access to everything.")
                }
                .onboardingReveal(index: 1)
            }
        }
        .padding(.horizontal, 32)
    }

    @ViewBuilder
    private func stepBullet(_ text: String) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Text("—")
                .font(WarmInstrument.monoLabel(13))
                .foregroundColor(WarmInstrument.inkFaint)
            Text(text)
                .font(.system(size: 14))
                .foregroundColor(WarmInstrument.inkMuted)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    @ViewBuilder
    private func numberedStep(_ n: Int, prefix: String, bold: String, suffix: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text("\(n)")
                .font(WarmInstrument.monoLabel(13))
                .foregroundColor(WarmInstrument.inkFaint)
                .frame(width: 16, alignment: .center)
            Text("\(prefix)\(Text(bold).fontWeight(.semibold))\(suffix)")
                .font(.system(size: 14))
                .foregroundColor(WarmInstrument.inkMuted)
                .fixedSize(horizontal: false, vertical: true)
                .lineSpacing(3)
        }
    }

    // MARK: - Action section

    private var actionSection: some View {
        VStack(spacing: 12) {
            if let error = errorMessage {
                Text(error)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(WarmInstrument.alarmFg)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 4)
            }

            // Primary button — hidden while auto-advancing (sign-in runs automatically)
            if !isAutoAdvancing {
                Button {
                    Haptics.tap()
                    if repoStepComplete {
                        continueToInstall()
                    } else {
                        openCreateRepo()
                    }
                } label: {
                    HStack(spacing: 10) {
                        if isInstalling {
                            ProgressView()
                                .tint(WarmInstrument.paper)
                                .scaleEffect(0.85)
                                .transition(.scale.combined(with: .opacity))
                        }
                        Text(primaryButtonLabel)
                            .contentTransition(.opacity)
                    }
                    .animation(PremiumMotion.press, value: isInstalling)
                }
                .buttonStyle(WarmSetupButtonStyle(primary: true))
                .disabled(primaryButtonDisabled)
                .onboardingReveal(index: 5)
            }

            // Secondary: re-run full sign-in for users whose server session expired.
            // Only shown on step 2 when not currently in-progress.
            if repoStepComplete && !isChecking && !isAutoAdvancing && !isInstalling {
                Button {
                    Haptics.tap()
                    signInAgain()
                } label: {
                    Text("Already linked? Sign in again")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(WarmInstrument.inkMuted)
                }
                .onboardingReveal(index: 6)
            }
        }
        .animation(PremiumMotion.onboardingReveal, value: repoStepComplete)
        .animation(PremiumMotion.state, value: isAutoAdvancing)
    }

    private var primaryButtonLabel: String {
        if repoStepComplete {
            return isInstalling ? "Opening GitHub…" : "Link Your Log"
        }
        return "Create Your Log"
    }

    private var primaryButtonDisabled: Bool {
        if repoStepComplete {
            return isInstalling || isChecking
        }
        return generateURL == nil || isChecking
    }

    // MARK: - Status checks

    /// Checks both prerequisites directly against GitHub's API.
    /// Step 1: does the coach-<login> repo exist?
    /// Step 2: does the coach-phelps App have access to it?
    /// When both pass, re-runs sign-in automatically to establish a server session.
    private func refreshSetupStatus() async {
        isChecking = true
        defer { isChecking = false }

        // Step 1 — repo
        let repoExists = await authManager.coachRepoExists(for: login)
        if !repoStepComplete {
            if !repoExists {
                // One retry — GitHub can lag a second after repo create.
                try? await Task.sleep(for: .seconds(1))
                repoStepComplete = await authManager.coachRepoExists(for: login)
            } else {
                repoStepComplete = true
            }
        }

        guard repoStepComplete else { return }

        // Step 2 — GitHub App installation (direct API, no server session dependency)
        let appInstalled = await authManager.coachAppInstalled(for: login)
        guard appInstalled else { return }
        installStepComplete = true

        // Both conditions met — re-run sign-in so the server can re-discover the
        // installation and issue a fresh session token.
        await autoAdvance()
    }

    /// Re-runs the full OAuth sign-in. GitHub cookies from the preceding sign-in make this
    /// silent for the user (WKWebView opens and closes without interaction). The server
    /// re-discovers the existing installation and issues a proper session token.
    private func autoAdvance() async {
        isAutoAdvancing = true
        defer { isAutoAdvancing = false }
        do {
            try await authManager.signIn()
            // Success: state transitions to .active and SetupView disappears.
            // If needs_setup=1 came back again, pendingSetupLogin stays set and this view
            // remains — fall through to show "Link Your Log" as a manual fallback.
        } catch {
            // Cancelled or network error — surface through errorMessage only if non-trivial.
            if !(error is WebAuthError) {
                errorMessage = UserFacingError.message(for: error, devMode: devModeEnabled)
            }
        }
    }

    // MARK: - Actions

    @MainActor
    private func markRepoComplete() {
        guard !repoStepComplete else { return }
        repoStepComplete = true
        Haptics.success()
        WebAuthPresenter.shared.dismissBrowse()
    }

    private func openCreateRepo() {
        guard let generateURL else { return }
        guard !repoStepComplete else { return }

        WebAuthPresenter.shared.presentBrowse(
            url: generateURL,
            onNavigation: { url in
                guard authManager.isCoachRepoCreationURL(url, login: login) else { return }
                Task { @MainActor in
                    markRepoComplete()
                }
            },
            onDismiss: {
                Task { @MainActor in
                    await refreshSetupStatus()
                }
            }
        )
    }

    private func continueToInstall() {
        isInstalling = true
        errorMessage = nil

        Task {
            do {
                try await authManager.continueToInstall()
                Haptics.success()
            } catch {
                errorMessage = UserFacingError.message(for: error, devMode: devModeEnabled)
                Haptics.error()
            }
            isInstalling = false
            // Intentionally no refreshSetupStatus() here — calling it re-arms autoAdvance()
            // because installStepComplete is already true, causing a browser open/close loop.
            // Use "Already linked? Sign in again" for manual recovery if the install succeeded
            // but the server callback didn't arrive.
        }
    }

    private func signInAgain() {
        errorMessage = nil
        Task {
            do {
                try await authManager.signIn()
                Haptics.success()
            } catch {
                errorMessage = UserFacingError.message(for: error, devMode: devModeEnabled)
                Haptics.error()
            }
        }
    }
}

// MARK: - HealthKit pre-permission screen

/// Shown once before the system HealthKit dialog — explains in plain language what Coach
/// reads and why, so the user isn't met cold by an OS permission sheet.
/// Health access is required; there is no skip option.
struct HealthKitPrePromptView: View {
    let onConnect: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Matches OnboardingRevealFlow header so dots sit at the same position
            HStack {
                Color.clear.frame(width: 36, height: 36)
                Spacer()
                OnboardingDots(step: 0, total: 5)
                    .onboardingReveal(index: 0)
                Spacer()
                Color.clear.frame(width: 36, height: 36)
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 4)

            VStack(alignment: .leading, spacing: 0) {
                Text("I read every\nworkout you do.")
                    .font(WarmInstrument.coachVoice(30))
                    .foregroundColor(WarmInstrument.ink)
                    .fixedSize(horizontal: false, vertical: true)
                    .onboardingReveal(index: 1)
                    .padding(.bottom, 20)

                Text("Duration, heart rate, sport type. That's how I learn your patterns and give you real feedback instead of generic advice.")
                    .font(WarmInstrument.coachVoice(15))
                    .foregroundColor(WarmInstrument.inkMuted)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineSpacing(4)
                    .onboardingReveal(index: 2)
            }
            .padding(.horizontal, 32)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)

            VStack(spacing: 12) {
                Button {
                    Haptics.tap()
                    onConnect()
                } label: {
                    Text("Connect Health")
                }
                .buttonStyle(WarmSetupButtonStyle(primary: true))
                .onboardingReveal(index: 3)

                Text("Health access is required for Coach to work.")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(WarmInstrument.inkFaint)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 8)
                    .onboardingReveal(index: 4)
            }
            .padding(.horizontal, 24)
            .safeAreaPadding(.bottom, 12)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(WarmInstrument.desk.ignoresSafeArea())
    }
}

// MARK: - Setup button style

struct WarmSetupButtonStyle: ButtonStyle {
    let primary: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 15, weight: .semibold))
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(primaryBackground(pressed: configuration.isPressed))
            .foregroundColor(primary ? WarmInstrument.paper : Theme.ink)
            .clipShape(RoundedRectangle(cornerRadius: WarmInstrument.cardRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: WarmInstrument.cardRadius, style: .continuous)
                    .strokeBorder(primary ? Color.clear : WarmInstrument.border, lineWidth: 1)
            )
            .shadow(color: primary ? WarmInstrument.cardShadow : .clear, radius: 10, y: 5)
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.spring(duration: 0.15, bounce: 0), value: configuration.isPressed)
    }

    private func primaryBackground(pressed: Bool) -> Color {
        if primary {
            return Theme.ink.opacity(pressed ? 0.85 : 1)
        }
        return WarmInstrument.surfaceMuted
    }
}
