import 'package:flutter/material.dart';
import 'package:zouhi/constants/constants.dart';
import 'package:zouhi/constants/theme_ext.dart';

class IconButtonSectoin extends StatefulWidget {
  Map<String, dynamic>? mapData;
  IconButtonSectoin({super.key, required this.mapData});

  @override
  State<IconButtonSectoin> createState() => _IconButtonSectoinState();
}

class _IconButtonSectoinState extends State<IconButtonSectoin>
    with AutomaticKeepAliveClientMixin {
  Map<String, dynamic>? iconData;
  int noOfColumn = 0;
  @override
  void initState() {
    iconData = widget.mapData?['columndata'];
    noOfColumn = int.parse(widget.mapData?['no_of_columns']);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: Padding(
        padding: pageSurroundingPadding,
        child: ListView.separated(
          shrinkWrap: true,
          itemCount: noOfColumn,
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
            return Card(
              clipBehavior: Clip.hardEdge,
              color: context.themeWhiteColor,
              elevation: 3,
              child: Container(
                decoration: BoxDecoration(
                    color: context.themegreyColor,
                    borderRadius: BorderRadius.circular(3),
                    image: DecorationImage(
                        colorFilter: ColorFilter.mode(
                            context.themegreyColor.withOpacity(0.5),
                            BlendMode.srcOver),
                        image: const AssetImage('assets/images/bg.png'),
                        fit: BoxFit.cover)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                child: Column(
                  children: [
                    const Icon(
                      Icons.category,
                      size: 30,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      iconData?[index.toString()]['link']['label'] ?? 'null',
                      style: TextStyle(fontFamily: 'Poppins', fontSize: 13),
                    ),
                  ],
                ),
              ),
            );
          },
          separatorBuilder: (context, index) => const SizedBox(
            width: 5,
          ),
        ),
      ),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
