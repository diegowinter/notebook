import 'package:flutter/material.dart';
import 'package:notebook/providers/collections.dart';
import 'package:notebook/providers/pages.dart';
import 'package:notebook/utils/app_routes.dart';
import 'package:provider/provider.dart';

class CollectionScreen extends StatelessWidget {
  final collectionId;
  CollectionScreen({ required this.collectionId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          Provider.of<Collections>(context, listen: false)
              .getCollectionTitle(collectionId),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.of(context).pushNamed(
            AppRoutes.PAGE_COMPOSER,
            arguments: collectionId
          );
        },
      ),
      body: Center(
        child: FutureBuilder(
          future: Provider.of<Pages>(context, listen: false).loadPages(collectionId),
          builder: (ctx, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            return Consumer<Pages>(
              builder: (ctx, pages, child) {
                if (pages.pagesCount == 0) {
                  return Center(
                    child: Text('As páginas desta coleção aparecerão aqui.'),
                  );
                }
                return ListView.builder(
                  itemCount: pages.pagesCount,
                  itemBuilder: (ctx, index) => Card(
                    child: ListTile(
                      title: Text(pages.pages[index].title),
                      onTap: () {
                        Navigator.of(context).pushNamed(
                          AppRoutes.PAGE_VIEWER,
                          arguments: pages.pages[index]
                        );
                      },
                    ),
                  ),
                );
              },
            );
          },
        )
      ),
    );
  }
}