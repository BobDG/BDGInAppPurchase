Pod::Spec.new do |s|
  s.name           = 'BDGInAppPurchase'
  s.version        = '0.0.2'
  s.summary        = 'Lightweight wrapper for In-App Purchases'
  s.license 	   = 'MIT'
  s.description    = 'Lightweight wrapper around storekit for easy In-App Purchases'
  s.homepage       = 'https://github.com/BobDG/BDGInAppPurchase'
  s.authors        = {'Bob de Graaf' => 'graafict@gmail.com'}
  s.source         = { :git => 'https://github.com/BobDG/BDGInAppPurchase.git', :tag => '0.0.2' }
  s.source_files   = '*.{h,m}'  
  s.frameworks     = 'StoreKit'
  s.platform       = :ios
  s.requires_arc   = true
end
