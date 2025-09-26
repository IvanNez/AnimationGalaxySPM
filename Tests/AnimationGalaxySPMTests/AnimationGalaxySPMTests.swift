import XCTest
@testable import AnimationGalaxySPM

final class AnimationGalaxySPMTests: XCTestCase {
    
    func testSplashScreenCreation() throws {
        // Тест проверяет создание splash screen с настройками по умолчанию
        let splashScreen = AnimationGalaxySPM.createSplashScreen()
        XCTAssertNotNil(splashScreen)
        
        // Тест с кастомными цветами
        let customSplashScreen = AnimationGalaxySPM.createSplashScreen(
            gradientColors: [.red, .orange, .yellow],
            textColor: .black,
            loaderColor: .blue,
            loadingText: "Загрузка..."
        )
        XCTAssertNotNil(customSplashScreen)
    }
    
    func testAnimationGalaxySPMInitialization() throws {
        // Тест проверяет, что пакет может быть импортирован и использован
        let starView = AnimationGalaxySPM.createAnimatedStar()
        XCTAssertNotNil(starView)
        
        let galaxyView = AnimationGalaxySPM.createGalaxy()
        XCTAssertNotNil(galaxyView)
        
        let spaceBackground = AnimationGalaxySPM.createSpaceBackground()
        XCTAssertNotNil(spaceBackground)
    }
    
    func testAnimatedStarWithCustomParameters() throws {
        let customStar = AnimationGalaxySPM.createAnimatedStar(
            size: 100,
            color: .red,
            duration: 2.0
        )
        XCTAssertNotNil(customStar)
    }
    
    func testGalaxyWithCustomParameters() throws {
        let customGalaxy = AnimationGalaxySPM.createGalaxy(
            elementCount: 12,
            size: 300,
            colors: [.green, .orange, .cyan]
        )
        XCTAssertNotNil(customGalaxy)
    }
    
    func testSpaceBackgroundWithCustomParameters() throws {
        let customBackground = AnimationGalaxySPM.createSpaceBackground(
            starCount: 100,
            speed: 3.0
        )
        XCTAssertNotNil(customBackground)
    }
}
