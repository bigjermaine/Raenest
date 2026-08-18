import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    private var coordinator: AppCoordinator?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }

        let navigationController = UINavigationController()
        navigationController.navigationBar.tintColor = AppColor.primary
        navigationController.navigationBar.prefersLargeTitles = true

        let coordinator = AppCoordinator(
            navigationController: navigationController,
            container: AppDependencyContainer()
        )
        self.coordinator = coordinator

        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = navigationController
        window.tintColor = AppColor.primary
        window.makeKeyAndVisible()
        self.window = window

        coordinator.start()
    }
}
