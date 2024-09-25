import 'package:flutter/material.dart';
import 'package:taga_cuyo/src/features/constants/colors.dart';
import 'package:taga_cuyo/src/features/constants/fontstyles.dart';

class ExplorePage extends StatelessWidget {
  const ExplorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body:  const Padding(
        padding: EdgeInsets.all(25.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionTitle(title: 'Tuklasin ang wikang Cuyonon'),
              SizedBox(height: 16),
              ExploreDescription(),
              SizedBox(height: 32),
              SectionTitle(title: 'Pagdiriwang sa Cuyo'),
              SizedBox(height: 16),
              FestivalList(),
              SizedBox(height: 32),
              SectionTitle(title: 'Sikat na Destinasyon', fontSize: 20),
              SizedBox(height: 16),
              DestinationList(),
            ],
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      title: Container(
        margin: const EdgeInsets.only(top: 20),
        child: const Text(
          'Maambeng nga Pag-abot!',
          style: TextStyle(fontFamily: AppFonts.lilitaOne, fontSize: 24),
        ),
      ),
      centerTitle: true,
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;
  final double fontSize;

  const SectionTitle({
    super.key,
    required this.title,
    this.fontSize = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.w900,
        fontFamily: AppFonts.kanitLight,
      ),
    );
  }
}

class ExploreDescription extends StatelessWidget {
  const ExploreDescription({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: AppColors.secondaryBackground,
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: const Text(
        'Ang Cuyonon ay miyembro ng sangay ng Pilipinas ng mga wikang Malayo—Polynesian. '
        'Pangunahing sinasalita ito sa Cuyo Islands, sa pagitan ng Northern Palawan at Panay Island sa '
        'Pilipinas, sa pagitan ng 93,000 at 120,000 katao. Ang wikang ito, ay sinasalita ng isang partikular '
        'na tao sa Palawan, at ito ang katutubong wika ng mga Cuyonon, ay nagsisilbing natatanging '
        'kultural na tradisyonal na kaalaman.',
        style: TextStyle(fontSize: 14, fontFamily: AppFonts.kanitLight),
        textAlign: TextAlign.justify,
      ),
    );
  }
}

class FestivalList extends StatelessWidget {
  const FestivalList({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildFestivalItem('Purogatan Festival', Colors.blueAccent),
          const SizedBox(width: 10),
          _buildFestivalItem('Purogatan Festival', Colors.greenAccent),
        ],
      ),
    );
  }

  Widget _buildFestivalItem(String title, Color color) {
    return Container(
      width: 150,
      color: color,
      child: Center(
        child: Text(
          title,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

class DestinationList extends StatelessWidget {
  const DestinationList({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildDestinationItem('Cuyo Town Beach', Colors.redAccent),
          const SizedBox(width: 10),
          _buildDestinationItem('St. Augustine\'s Church', Colors.orangeAccent),
        ],
      ),
    );
  }

  Widget _buildDestinationItem(String title, Color color) {
    return Container(
      width: 150,
      color: color,
      child: Center(
        child: Text(
          title,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
