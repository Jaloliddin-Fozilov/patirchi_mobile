import '../models/product_model.dart';
import '../models/shop_model.dart';

/// Lokal (offline) datasource — API mavjud bo'lmaganda fallback ma'lumot.
///
/// Remote API bilan integratsiya qilingandan keyin ham ushbu sinf
/// offline rejim uchun zaxira sifatida ishlatiladi.
class BuyerHomeLocalDatasource {
  static final List<ShopModel> shops = [
    const ShopModel(
      id: 1,
      name: 'Patirchi Markaziy',
      phoneNumber: '',
      address: "Toshkent sh., Chilonzor tumani, Muqimiy ko'chasi 44-uy",
      isOpen: true,
      openingTime: '08:00:00',
      closingTime: '22:00:00',
      storeType: 'bakery',
      latitude: 41.2856,
      longitude: 69.2044,
    ),
    const ShopModel(
      id: 2,
      name: 'Oq Oltin Nonvoyxonasi',
      phoneNumber: '',
      address: 'Toshkent sh., Yunusobod tumani, 12-kv',
      isOpen: true,
      openingTime: '07:00:00',
      closingTime: '21:00:00',
      storeType: 'bakery',
      latitude: 41.3407,
      longitude: 69.2861,
    ),
    const ShopModel(
      id: 3,
      name: 'Samarqand Patir',
      phoneNumber: '',
      address: "Toshkent sh., Shayhontohur tumani, Navoiy ko'chasi 15",
      isOpen: false,
      openingTime: '06:00:00',
      closingTime: '20:00:00',
      storeType: 'bakery',
      latitude: 41.3185,
      longitude: 69.2520,
    ),
    const ShopModel(
      id: 4,
      name: 'Non Olami',
      phoneNumber: '',
      address: "Toshkent sh., Mirzo Ulug'bek tumani",
      isOpen: true,
      openingTime: '07:30:00',
      closingTime: '22:30:00',
      storeType: 'bakery',
      latitude: 41.3375,
      longitude: 69.3050,
    ),
    const ShopModel(
      id: 5,
      name: 'Mazzali non',
      phoneNumber: '',
      address: 'Turan, 6/10, Zarkaynar Street',
      isOpen: false,
      openingTime: '07:00:00',
      closingTime: '16:00:00',
      storeType: 'bakery',
      latitude: 41.3125,
      longitude: 69.2452,
    ),
    const ShopModel(
      id: 6,
      name: 'Toshkent Patiri',
      phoneNumber: '',
      address: 'Toshkent sh., Yakkasaroy tumani, Shota Rustaveli 12',
      isOpen: true,
      openingTime: '06:30:00',
      closingTime: '21:00:00',
      storeType: 'bakery',
      latitude: 41.2975,
      longitude: 69.2780,
    ),
  ];

  static final List<ProductModel> products = [
    ProductModel(
      id: 1,
      name: 'Qoqon patir',
      price: 5000,
      weight: 1000,
      description:
          "An'anaviy Qo'qon patiri, tandir nondan tayyorlangan. Yumshoq va xushbo'y.",
      store: const StoreInfo(id: 1, name: 'Patirchi Markaziy'),
      firstImage:
          'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=400&h=400&fit=crop',
    ),
    ProductModel(
      id: 2,
      name: 'Tandir non',
      price: 3000,
      weight: 400,
      description: 'Yangi pishirilgan tandir noni. Har kuni ertalab tayyorlanadi.',
      store: const StoreInfo(id: 1, name: 'Patirchi Markaziy'),
      firstImage:
          'https://images.unsplash.com/photo-1549931319-a545dcf3bc73?w=400&h=400&fit=crop',
    ),
    ProductModel(
      id: 3,
      name: "Go'shtli somsa",
      price: 8000,
      weight: 200,
      description: 'Tandirda pishirilgan go\'shtli somsa. Issiq holda beriladi.',
      store: const StoreInfo(id: 2, name: 'Oq Oltin Nonvoyxonasi'),
      firstImage:
          'https://images.unsplash.com/photo-1586985289688-ca3cf47d3e6e?w=400&h=400&fit=crop',
    ),
    ProductModel(
      id: 4,
      name: 'Obi non',
      price: 2500,
      weight: 350,
      description: "Yumshoq obi non, har kuni yangi pishiriladi.",
      store: const StoreInfo(id: 2, name: 'Oq Oltin Nonvoyxonasi'),
      firstImage:
          'https://images.unsplash.com/photo-1585478259715-876acc5be8eb?w=400&h=400&fit=crop',
    ),
    ProductModel(
      id: 5,
      name: 'Samarqand noni',
      price: 6000,
      weight: 500,
      description:
          "Mashhur Samarqand noni, an'anaviy retsept bo'yicha tayyorlangan.",
      store: const StoreInfo(id: 3, name: 'Samarqand Patir'),
      firstImage:
          'https://images.unsplash.com/photo-1608198093002-ad4e005484ec?w=400&h=400&fit=crop',
    ),
    ProductModel(
      id: 6,
      name: 'Katlama',
      price: 7000,
      weight: 300,
      description: "Qatlamali yog'li non, qizdirilganda juda mazali.",
      store: const StoreInfo(id: 1, name: 'Patirchi Markaziy'),
      firstImage:
          'https://images.unsplash.com/photo-1590137876181-2a5a7e340de2?w=400&h=400&fit=crop',
    ),
    ProductModel(
      id: 7,
      name: 'Yupqa non',
      price: 2000,
      weight: 150,
      description: "Yupqa lavash noni, o'rab yeyish uchun ideal.",
      store: const StoreInfo(id: 4, name: 'Non Olami'),
      firstImage:
          'https://images.unsplash.com/photo-1600398142498-be599a4ae9b4?w=400&h=400&fit=crop',
    ),
    ProductModel(
      id: 8,
      name: 'Chalpak',
      price: 4000,
      weight: 250,
      description: 'Shirin chalpak noni, choy bilan juda yoqimli.',
      store: const StoreInfo(id: 4, name: 'Non Olami'),
      firstImage:
          'https://images.unsplash.com/photo-1555507036-ab1f4038024a?w=400&h=400&fit=crop',
    ),
    ProductModel(
      id: 9,
      name: "Yog'li patir",
      price: 5000,
      weight: 450,
      description: "Yog'li patir noni, tandirda pishirilgan.",
      store: const StoreInfo(id: 5, name: 'Mazzali non'),
      firstImage:
          'https://images.unsplash.com/photo-1598373182133-52452f7691ef?w=400&h=400&fit=crop',
    ),
    ProductModel(
      id: 10,
      name: 'Kulcha non',
      price: 3500,
      weight: 300,
      description: "Yumshoq kulcha noni, an'anaviy usulda tayyorlangan.",
      store: const StoreInfo(id: 5, name: 'Mazzali non'),
      firstImage:
          'https://images.unsplash.com/photo-1517686469429-8bae29a7990a?w=400&h=400&fit=crop',
    ),
    ProductModel(
      id: 11,
      name: 'Non lepyoshka',
      price: 4500,
      weight: 400,
      description: 'Klassik lepyoshka, issiq holda beriladi.',
      store: const StoreInfo(id: 6, name: 'Toshkent Patiri'),
      firstImage:
          'https://images.unsplash.com/photo-1574085733277-851d9d856a3a?w=400&h=400&fit=crop',
    ),
    ProductModel(
      id: 12,
      name: 'Shirmon non',
      price: 6000,
      weight: 500,
      description: 'Shirmon noni - katta hajmda, oila uchun ideal.',
      store: const StoreInfo(id: 6, name: 'Toshkent Patiri'),
      firstImage:
          'https://images.unsplash.com/photo-1589367920969-ab8e050bbb04?w=400&h=400&fit=crop',
    ),
  ];

  static final List<String> categories = [
    'Barchasi',
    'Nonushta',
    'Tandir non',
    'Patir',
    'Somsa',
    'Shirin',
    'Lavash',
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
