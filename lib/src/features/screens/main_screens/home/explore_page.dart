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
        padding: EdgeInsets.fromLTRB(20, 20, 0, 0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionTitle(title: 'Tuklasin ang wikang Cuyonon', fontSize: 18),
              SizedBox(height: 16),
              Padding(
                padding: EdgeInsets.only(right: 20.0),
                child: ExploreDescription(),
              ),
              SizedBox(height: 32),
              SectionTitle(title: 'Pagdiriwang sa Cuyo', fontSize: 18),
              SizedBox(height: 16),
              FestivalList(),
              SizedBox(height: 32),
              SectionTitle(title: 'Sikat na Destinasyon', fontSize: 18),
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
      padding: const EdgeInsets.all(25),
      decoration: const BoxDecoration(
        color: AppColors.secondaryBackground,
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: const Text(
        '"Tuklasin ang mayamang pamana ng Cuyo—kung saan buhay na buhay ang wikang Cuyonon, makulay na tradisyon, at daang-taong kasaysayan. Matuto, mag-explore, at kumonekta sa pusong kultural ng Pilipinas."',
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
    final screenSize = MediaQuery.of(context).size;

    final double itemWidth = screenSize.width * 0.6; // 60% of screen width
    final double itemHeight = screenSize.height * 0.25; // 25% of screen height

    return SizedBox(
      height: itemHeight,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildFestivalItem('Purongitan Festival', 'assets/images/purongitan.jpg', itemWidth, itemHeight),
          const SizedBox(width: 10),
          _buildFestivalItem('Ati Ati of Cuyo', 'assets/images/purongitan_2.jpg', itemWidth, itemHeight),
        ],
      ),
    );
  }

  Widget _buildFestivalItem(String title, String imagePath, double width, double height) {
  return Container(
    width: width,
    height: height,
    padding: const EdgeInsets.symmetric(horizontal: 10),
    decoration: BoxDecoration(
      image: DecorationImage(
        image: AssetImage(imagePath),
        fit: BoxFit.cover,
      ),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween, // Align items within the column
      children: [
        const SizedBox(), // This can be used to push the title down
        Container(
          width: width*0.7, // Use the same width as the parent container
          height: 30, // Adjust height as needed
          color: AppColors.titleColor,
          child: Center( // Center the text horizontally and vertically
            child: Text(
              title,
              style: const TextStyle(color: Colors.white,fontFamily: AppFonts.fcr, fontSize: 21),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    ),
  );
}

}

class DestinationList extends StatelessWidget {
  const DestinationList({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    final double itemWidth = screenSize.width * 0.6; // 60% of screen width
    final double itemHeight = screenSize.height * 0.25; // 25% of screen height

    return SizedBox(
      height: itemHeight,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildDestinationItem('Capusan Beach', 'assets/images/capusan_beach.jpg', itemWidth, itemHeight),
          const SizedBox(width: 10),
          _buildDestinationItem('St. Augustine\'s Church', 'assets/images/fort_cuyo.jpg', itemWidth, itemHeight),
        ],
      ),
    );
  }

  Widget _buildDestinationItem(String title, String imagePath, double width, double height) {
    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(imagePath),
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(),
          Container(
            width: width * 0.7,
            height: 30,
            color: AppColors.titleColor,
            child: Center(
              child: Text(
                title,
                style: const TextStyle(color: Colors.white, fontFamily: AppFonts.fcr, fontSize: 21),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
