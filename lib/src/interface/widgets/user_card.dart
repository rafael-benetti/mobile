import 'package:flutter/material.dart';
import '../../core/models/user.dart';
import '../shared/colors.dart';
import '../shared/text_styles.dart';

import '../../locator.dart';

final styles = locator<TextStyles>();
final colors = locator<AppColors>();

class UserCard extends StatelessWidget {
  final User user;

  const UserCard({Key key, this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(3),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        color: colors.backgroundColor,
        boxShadow: [
          BoxShadow(
            blurRadius: 2,
            spreadRadius: 2,
            color: colors.lightBlack,
            offset: Offset(1, 1),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 55,
            height: 55,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(60),
              child: user.photo != null
                  ? Image.network(
                      user.photo,
                      fit: BoxFit.cover,
                    )
                  : Image.asset(
                      'assets/user_thumbnail.png',
                      fit: BoxFit.cover,
                    ),
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      child: Text(
                        'Nome:',
                        style: styles.medium(fontSize: 15),
                      ),
                    ),
                    SizedBox(width: 5),
                    Container(
                      child: Text(
                        user.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        user.isActive ? 'Ativo' : 'Inativo',
                        style: styles.medium(
                            color:
                                user.isActive ? colors.lightGreen : colors.red),
                        textAlign: TextAlign.end,
                      ),
                    )
                  ],
                ),
                SizedBox(height: 7.5),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      child: Text(
                        'Email:',
                        style: styles.medium(fontSize: 15),
                      ),
                    ),
                    SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        user.email,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
