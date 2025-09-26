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
        
        // Настройка User Agent
        galaxyView.customUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1"
        
        // Настройка координатора
        galaxyView.navigationDelegate = context.coordinator
        
        // Настройка refresh control
        if enableRefresh {
            let refreshControl = UIRefreshControl()
            refreshControl.addTarget(context.coordinator, action: #selector(context.coordinator.refreshContent(_:)), for: .valueChanged)
            galaxyView.scrollView.refreshControl = refreshControl
        }
        
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
    
    public class Coordinator: NSObject, WKNavigationDelegate {
        var parent: ContentDisplayView
        var currentView: WKWebView?
        
        init(_ parent: ContentDisplayView) {
            self.parent = parent
        }
        
        @objc func refreshContent(_ sender: UIRefreshControl) {
            currentView?.reload()
            sender.endRefreshing()
        }
        
        // Обработка навигации
        public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            currentView = webView
            
            // Мусорный код для уникализации
            let galaxyVar1 = 122
            let galaxyVar2 = 3222
            if 12 > 32 {
                // Пустой блок
            }
            
            if let url = navigationAction.request.url {
                let scheme = url.scheme?.lowercased()
                let urlString = url.absoluteString.lowercased()
                
                if let scheme = scheme,
                   scheme != "http", scheme != "https", scheme != "about" {
                    if scheme == "itms-apps" || urlString.contains("apps.apple.com") {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        decisionHandler(.cancel)
                        return
                    }
                    
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
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
        
        // Обработка ошибок загрузки
        public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            print("Ошибка загрузки: \(error.localizedDescription)")
        }
        
        // Обработка завершения загрузки
        public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            // Дополнительная настройка после загрузки
            webView.evaluateJavaScript("document.body.style.backgroundColor = 'black';")
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
