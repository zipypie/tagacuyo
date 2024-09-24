import 'package:flutter/material.dart';
import 'package:taga_cuyo/src/features/constants/colors.dart';
import 'package:taga_cuyo/src/features/constants/fontstyles.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cuyonon Language App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomeScreenPage(),
    );
  }
}

class HomeScreenPage extends StatelessWidget {
  const HomeScreenPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Container(
          margin: const EdgeInsets.only(top: 20), // Add margin for spacing
          child: const Text(
            'Maambeng nga Pag-abot!',
            style: TextStyle(fontFamily: AppFonts.lilitaOne, fontSize: 24),
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tuklasin ang wikang Cuyonon',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900,fontFamily: AppFonts.kanitLight),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: AppColors.secondaryBackground,
                  borderRadius: BorderRadius.all(
                      Radius.circular(10)), // Apply border radius
                ),
                child: const Text(
                  'Ang Cuyonon ay miyembro ng sangay ng Pilipinas ng mga wikang Malayo—Polynesian. '
                  'Pangunahing sinasalita ito sa Cuyo Islands, sa pagitan ng Northern Palawan at Panay Island sa '
                  'Pilipinas, sa pagitan ng 93,000 at 120,000 katao. Ang wikang ito, ay sinasalita ng isang partikular '
                  'na tao sa Palawan, at ito ang katutubong wika ng mga Cuyonon, ay nagsisilbing natatanging '
                  'kultural na tradisyonal na kaalaman.',
                  style:
                      TextStyle(fontSize: 14, fontFamily: AppFonts.kanitLight),
                  textAlign: TextAlign.justify,
                ),
              ),

              const SizedBox(height: 32),
              const Text(
                'Pagdiriwang sa Cuyo',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900,fontFamily: AppFonts.kanitLight),
              ),
              const SizedBox(height: 16),
              // Placeholder for images related to the festival
              SizedBox(
                height: 200,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    Container(
                      width: 150,
                      color: Colors.blueAccent,
                      child: const Center(child: Text('Purogatan Festival')),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      width: 150,
                      color: Colors.greenAccent,
                      child: const Center(child: Text('Purogatan Festival')),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Sikat na Destinasyon',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              // Placeholder for destination images
              SizedBox(
                height: 200,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    Container(
                      width: 150,
                      color: Colors.redAccent,
                      child: const Center(child: Text('Cuyo Town Beach')),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      width: 150,
                      color: Colors.orangeAccent,
                      child:
                          const Center(child: Text('St. Augustine\'s Church')),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
