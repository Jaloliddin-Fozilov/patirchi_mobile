import '../models/product_model.dart';
import '../models/shop_model.dart';

class BuyerHomeLocalDatasource {
  static final List<ShopModel> shops = [
    const ShopModel(
      id: '1', name: 'Patirchi Markaziy', ownerName: 'Abdullayev Jasur',
      isOpen: true, openTime: '08:00', closeTime: '22:00',
      address: 'Toshkent sh., Chilonzor tumani, Muqimiy ko\'chasi 44-uy',
      district: 'Chilonzor', rating: 4.8, shopType: 'bakery',
      latitude: 41.2856, longitude: 69.2044,
    ),
    const ShopModel(
      id: '2', name: 'Oq Oltin Nonvoyxonasi', ownerName: 'Karimov Sanjar',
      isOpen: true, openTime: '07:00', closeTime: '21:00',
      address: 'Toshkent sh., Yunusobod tumani, 12-kv',
      district: 'Yunusobod', rating: 4.6, shopType: 'bakery',
      latitude: 41.3407, longitude: 69.2861,
    ),
    const ShopModel(
      id: '3', name: 'Samarqand Patir', ownerName: 'Rahimov Bobur',
      isOpen: false, openTime: '06:00', closeTime: '20:00',
      address: 'Toshkent sh., Shayhontohur tumani, Navoiy ko\'chasi 15',
      district: 'Shayhontohur', rating: 4.9, shopType: 'bakery',
      latitude: 41.3185, longitude: 69.2520,
    ),
    const ShopModel(
      id: '4', name: 'Non Olami', ownerName: 'Toshmatov Ulug\'bek',
      isOpen: true, openTime: '07:30', closeTime: '22:30',
      address: 'Toshkent sh., Mirzo Ulug\'bek tumani',
      district: 'Mirzo Ulug\'bek', rating: 4.4, shopType: 'bakery',
      latitude: 41.3375, longitude: 69.3050,
    ),
    const ShopModel(
      id: '5', name: 'Mazzali non', ownerName: 'Tursunov Baxtiyor',
      isOpen: false, openTime: '07:00', closeTime: '16:00',
      address: 'Turan, 6/10, Zarkaynar Street, Khasti...',
      district: 'Olmazor', rating: 4.7, shopType: 'bakery',
      latitude: 41.3125, longitude: 69.2452,
    ),
    const ShopModel(
      id: '6', name: 'Toshkent Patiri', ownerName: 'Aliyev Nodir',
      isOpen: true, openTime: '06:30', closeTime: '21:00',
      address: 'Toshkent sh., Yakkasaroy tumani, Shota Rustaveli 12',
      district: 'Yakkasaroy', rating: 4.5, shopType: 'bakery',
      latitude: 41.2975, longitude: 69.2780,
    ),
  ];

  static final List<ProductModel> products = [
    ProductModel(
      id: '1', name: 'Qoqon patir', price: 5000, oldPrice: 8000, discountPercent: 38,
      weight: 1, weightUnit: 'dona',
      ingredients: ['un', 'suv', 'tuz', 'yog\''],
      description: 'An\'anaviy Qo\'qon patiri, tandir nondan tayyorlangan. Yumshoq va xushbo\'y.',
      shopId: '1', shopName: 'Patirchi Markaziy',
      imageUrl: 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=400&h=400&fit=crop',
    ),
    ProductModel(
      id: '2', name: 'Tandir non', price: 3000, oldPrice: 4500, discountPercent: 33,
      weight: 400, weightUnit: 'g',
      ingredients: ['un', 'suv', 'tuz', 'sedana'],
      description: 'Yangi pishirilgan tandir noni. Har kuni ertalab tayyorlanadi.',
      shopId: '1', shopName: 'Patirchi Markaziy',
      imageUrl: 'https://images.unsplash.com/photo-1549931319-a545dcf3bc73?w=400&h=400&fit=crop',
    ),
    ProductModel(
      id: '3', name: 'Go\'shtli somsa', price: 8000, oldPrice: 12000, discountPercent: 33,
      weight: 200, weightUnit: 'g',
      ingredients: ['un', 'go\'sht', 'piyoz', 'tuz', 'zira'],
      description: 'Tandirda pishirilgan go\'shtli somsa. Issiq holda beriladi.',
      shopId: '2', shopName: 'Oq Oltin Nonvoyxonasi',
      imageUrl: 'https://images.unsplash.com/photo-1586985289688-ca3cf47d3e6e?w=400&h=400&fit=crop',
    ),
    ProductModel(
      id: '4', name: 'Obi non', price: 2500,
      weight: 350, weightUnit: 'g',
      ingredients: ['un', 'suv', 'tuz'],
      description: 'Yumshoq obi non, har kuni yangi pishiriladi.',
      shopId: '2', shopName: 'Oq Oltin Nonvoyxonasi',
      imageUrl: 'https://images.unsplash.com/photo-1585478259715-876acc5be8eb?w=400&h=400&fit=crop',
    ),
    ProductModel(
      id: '5', name: 'Samarqand noni', price: 6000, oldPrice: 9000, discountPercent: 33,
      weight: 500, weightUnit: 'g',
      ingredients: ['un', 'suv', 'tuz', 'sedana', 'yog\''],
      description: 'Mashhur Samarqand noni, an\'anaviy retsept bo\'yicha tayyorlangan.',
      shopId: '3', shopName: 'Samarqand Patir',
      imageUrl: 'https://images.unsplash.com/photo-1608198093002-ad4e005484ec?w=400&h=400&fit=crop',
    ),
    ProductModel(
      id: '6', name: 'Katlama', price: 7000,
      weight: 300, weightUnit: 'g',
      ingredients: ['un', 'yog\'', 'tuz'],
      description: 'Qatlamali yog\'li non, qizdirilganda juda mazali.',
      shopId: '1', shopName: 'Patirchi Markaziy',
      imageUrl: 'https://images.unsplash.com/photo-1590137876181-2a5a7e340de2?w=400&h=400&fit=crop',
    ),
    ProductModel(
      id: '7', name: 'Yupqa non', price: 2000, oldPrice: 3500, discountPercent: 43,
      weight: 150, weightUnit: 'g',
      ingredients: ['un', 'suv', 'tuz'],
      description: 'Yupqa lavash noni, o\'rab yeyish uchun ideal.',
      shopId: '4', shopName: 'Non Olami',
      imageUrl: 'https://images.unsplash.com/photo-1600398142498-be599a4ae9b4?w=400&h=400&fit=crop',
    ),
    ProductModel(
      id: '8', name: 'Chalpak', price: 4000,
      weight: 250, weightUnit: 'g',
      ingredients: ['un', 'yog\'', 'shakar', 'tuxum'],
      description: 'Shirin chalpak noni, choy bilan juda yoqimli.',
      shopId: '4', shopName: 'Non Olami',
      imageUrl: 'https://images.unsplash.com/photo-1555507036-ab1f4038024a?w=400&h=400&fit=crop',
    ),
    ProductModel(
      id: '9', name: 'Yog\'li patir', price: 5000,
      weight: 450, weightUnit: 'g',
      ingredients: ['un', 'yog\'', 'tuz', 'suv'],
      description: 'Yog\'li patir noni, tandirda pishirilgan.',
      shopId: '5', shopName: 'Mazzali non',
      imageUrl: 'https://images.unsplash.com/photo-1598373182133-52452f7691ef?w=400&h=400&fit=crop',
    ),
    ProductModel(
      id: '10', name: 'Kulcha non', price: 3500,
      weight: 300, weightUnit: 'g',
      ingredients: ['un', 'suv', 'tuz', 'sedana'],
      description: 'Yumshoq kulcha noni, an\'anaviy usulda tayyorlangan.',
      shopId: '5', shopName: 'Mazzali non',
      imageUrl: 'https://images.unsplash.com/photo-1517686469429-8bae29a7990a?w=400&h=400&fit=crop',
    ),
    ProductModel(
      id: '11', name: 'Non lepyoshka', price: 4500,
      weight: 400, weightUnit: 'g',
      ingredients: ['un', 'suv', 'tuz', 'piyoz'],
      description: 'Klassik lepyoshka, issiq holda beriladi.',
      shopId: '6', shopName: 'Toshkent Patiri',
      imageUrl: 'https://images.unsplash.com/photo-1574085733277-851d9d856a3a?w=400&h=400&fit=crop',
    ),
    ProductModel(
      id: '12', name: 'Shirmon non', price: 6000, oldPrice: 8000, discountPercent: 25,
      weight: 500, weightUnit: 'g',
      ingredients: ['un', 'yog\'', 'suv', 'tuz'],
      description: 'Shirmon noni - katta hajmda, oila uchun ideal.',
      shopId: '6', shopName: 'Toshkent Patiri',
      imageUrl: 'https://images.unsplash.com/photo-1589367920969-ab8e050bbb04?w=400&h=400&fit=crop',
    ),
  ];

  static final List<String> categories = [
    'Barchasi', 'Nonushta', 'Tandir non', 'Patir', 'Somsa', 'Shirin', 'Lavash',
  ];

  static final List<Map<String, dynamic>> promoBanners = [
    {
      'title': 'PATIRCHI AKSIYASI',
      'subtitle': 'Birinchi buyurtmangizga',
      'discount': '-20%',
      'gradient': [0xFFFA6400, 0xFFFF8A50],
    },
    {
      'title': 'YANGI NONVOYXONA',
      'subtitle': 'Samarqand Patir ochildi!',
      'discount': '-15%',
      'gradient': [0xFFE91E63, 0xFFFF5252],
    },
  ];

  static final List<Map<String, dynamic>> quickServices = [
    {'icon': 'storefront', 'label': 'Nonvoy\nxonalar'},
    {'icon': 'local_offer', 'label': 'Aksiya\nlar'},
    {'icon': 'delivery_dining', 'label': 'Yetkazib\nberish'},
    {'icon': 'work_outline', 'label': 'Vakansiya\nlar'},
    {'icon': 'star_outline', 'label': 'Top\nmahsulot'},
  ];
}