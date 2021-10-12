import 'package:flutter/material.dart'; 
import 'package:font_awesome_flutter/font_awesome_flutter.dart';  
import 'package:medicpro/src/utils/variables.dart'; 

class ImagenesDetallePage extends StatefulWidget {
  final int index;
  final List fotos;
  const ImagenesDetallePage(this.index, this.fotos);

  @override
  State<ImagenesDetallePage> createState() => _ImagenesDetallePageState();
}

class _ImagenesDetallePageState extends State<ImagenesDetallePage> {
  late PageController controller;

  @override
  void initState() {
    controller = PageController(initialPage: widget.index);
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  createPage(query, page) {
    return Hero(
      tag: widget.fotos[page]["imagen"],
      child: FadeInImage(
        width: query.width,
        placeholder: AssetImage("assets/imgs/no-image.png"),
        image: NetworkImage(
          baseUrlSsl + widget.fotos[page]["imagen"],
        ),
        fit: BoxFit.contain,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final query = MediaQuery.of(context).size;
 
    return Scaffold(
      body: Stack(
        children: [
          Container(
            color: Colors.black,
            child: PageView.builder(
              controller: controller,
              physics: BouncingScrollPhysics(),
              itemCount: widget.fotos.length, 
              itemBuilder: (context, position) {
                return createPage(query, position);
              },
            ),
          ),
          AppBarrImage(widget.fotos),
        ],
      ),
    );
  }
}

class AppBarrImage extends StatelessWidget {
  
  final fotos;

  const AppBarrImage(this.fotos );

  @override
  Widget build(BuildContext context) { 
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 15,
        top: 30,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 30,
              height: 30,
              child: FaIcon(
                FontAwesomeIcons.chevronLeft,
                color: Colors.white,
              ),
            ),
          ), 
        ],
      ),
    );
  }
}
