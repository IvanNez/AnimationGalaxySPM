import SwiftUI
import WebKit

/// Конфигурация для отображения веб-контента
public struct ContentDisplayView: UIViewRepresentable {
    let urlString: String
    let allowsGestures: Bool
    let enableRefresh: Bool
    
    public init(urlString: String, allowsGestures: Bool = true, enableRefresh: Bool = true) {
        self.urlString = urlString
        self.allowsGestures = allowsGestures
        self.enableRefresh = enableRefresh
    }
    
    public func makeUIView(context: Context) -> WKWebView {
        let galaxyConfig = WKWebViewConfiguration()
        let galaxyPreferences = WKWebpagePreferences()
        
        // Настройка JavaScript
        galaxyPreferences.allowsContentJavaScript = true
        galaxyConfig.defaultWebpagePreferences = galaxyPreferences
        
        // Настройка медиа
        galaxyConfig.allowsInlineMediaPlayback = true
        galaxyConfig.mediaTypesRequiringUserActionForPlayback = []
        galaxyConfig.allowsAirPlayForMediaPlayback = true
        galaxyConfig.allowsPictureInPictureMediaPlayback = true
        
        // Настройка данных сайта
        galaxyConfig.websiteDataStore = WKWebsiteDataStore.default()
        
        // Создание WebView
        let galaxyView = WKWebView(frame: .zero, configuration: galaxyConfig)
        
        // Настройка жестов
        galaxyView.allowsBackForwardNavigationGestures = allowsGestures
        
        // Настройка User Agent (iOS 18 Safari)
        galaxyView.customUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 18_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.0 Mobile/15E148 Safari/604.1"
        
        // Настройка координатора
        galaxyView.navigationDelegate = context.coordinator
        galaxyView.uiDelegate = context.coordinator
        
        // Настройка refresh control
        let galaxyRefreshControl = UIRefreshControl()
        galaxyRefreshControl.addTarget(context.coordinator, action: #selector(context.coordinator.refreshContent(_:)), for: .valueChanged)
        galaxyView.scrollView.refreshControl = galaxyRefreshControl
        
        // Сохраняем ссылки в координаторе
        context.coordinator.galaxyWVView = galaxyView
        context.coordinator.galaxyRefreshControl = galaxyRefreshControl
        
        return galaxyView
    }
    
    public func updateUIView(_ uiView: WKWebView, context: Context) {
        guard let url = URL(string: urlString) else { return }
        let request = URLRequest(url: url)
        uiView.load(request)
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    public class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
        var parent: ContentDisplayView
        weak var galaxyWVView: WKWebView?
        weak var galaxyRefreshControl: UIRefreshControl?
        
        init(_ parent: ContentDisplayView) {
            self.parent = parent
        }
        
        @objc func refreshContent(_ sender: UIRefreshControl) {
            galaxyWVView?.reload()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                self?.galaxyRefreshControl?.endRefreshing()
            }
        }
        
        // Обработка навигации
        public func webView(_ galaxyWebView: WKWebView, decidePolicyFor galaxyNavigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            // Мусорный код для уникализации
            let galaxyVar1 = 122
            let galaxyVar2 = 3222
            if 12 > 32 {
                // Пустой блок
            }
            
            if let galaxyUrl = galaxyNavigationAction.request.url {
                let galaxyScheme = galaxyUrl.scheme?.lowercased()
                let galaxyUrlString = galaxyUrl.absoluteString.lowercased()
                
                if let galaxyScheme = galaxyScheme,
                   galaxyScheme != "http", galaxyScheme != "https", galaxyScheme != "about" {
                    if galaxyScheme == "itms-apps" || galaxyUrlString.contains("apps.apple.com") {
                        UIApplication.shared.open(galaxyUrl, options: [:], completionHandler: nil)
                        decisionHandler(.cancel)
                        return
                    }
                    
                    UIApplication.shared.open(galaxyUrl, options: [:], completionHandler: nil)
                    decisionHandler(.cancel)
                    return
                }
            }
            
            decisionHandler(.allow)
        }
        
        // Обработка дочерних окон
        public func webView(_ galaxyDisplayView: WKWebView, createWebViewWith galaxyDisplayConfiguration: WKWebViewConfiguration, for galaxyDisplayNavigationAction: WKNavigationAction, windowFeatures galaxyDisplayWindowFeatures: WKWindowFeatures) -> WKWebView? {
            
            // Мусорный код
            let spaceVar1 = 456
            let spaceVar2 = 789
            if 15 < 25 {
                // Пустой блок
            }
            
            if galaxyDisplayNavigationAction.targetFrame == nil {
                if let galaxyDisplayUrl = galaxyDisplayNavigationAction.request.url {
                    let galaxyDisplayRequest = URLRequest(url: galaxyDisplayUrl)
                    galaxyDisplayView.load(galaxyDisplayRequest)
                }
            }
            return nil
        }
        
        // Обработка начала навигации
        public func webView(_ galaxyWebView: WKWebView, didStartProvisionalNavigation galaxyNavigation: WKNavigation!) {
            // Опциональная обработка начала навигации
        }
        
        // Обработка завершения загрузки
        public func webView(_ galaxyWebView: WKWebView, didFinish galaxyNavigation: WKNavigation!) {
            galaxyRefreshControl?.endRefreshing()
        }
        
        // Обработка ошибок загрузки
        public func webView(_ galaxyWebView: WKWebView, didFail galaxyNavigation: WKNavigation!, withError galaxyError: Error) {
            galaxyRefreshControl?.endRefreshing()
        }
        
        // Обработка ошибок загрузки (провизорная навигация)
        public func webView(_ galaxyWebView: WKWebView, didFailProvisionalNavigation galaxyNavigation: WKNavigation!, withError galaxyError: Error) {
            print("Ошибка загрузки: \(galaxyError.localizedDescription)")
        }
    }
}

/// SwiftUI обертка для ContentDisplayView с отступами от safe area
public struct SafeContentDisplayView: View {
    let urlString: String
    let allowsGestures: Bool
    let enableRefresh: Bool
    
    public init(urlString: String, allowsGestures: Bool = true, enableRefresh: Bool = true) {
        self.urlString = urlString
        self.allowsGestures = allowsGestures
        self.enableRefresh = enableRefresh
    }
    
    public var body: some View {
        ZStack {
            // Черный фон
            Color.black
                .ignoresSafeArea()
            
            // WebView с отступами от safe area
            ContentDisplayView(
                urlString: urlString,
                allowsGestures: allowsGestures,
                enableRefresh: enableRefresh
            )
            .padding(.top, 20) // Отступ сверху
            .padding(.bottom, 20) // Отступ снизу
        }
    }
}
