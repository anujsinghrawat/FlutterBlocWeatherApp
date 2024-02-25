import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:weather/Bloc/AuthBloc/auth_bloc.dart';
import 'package:weather/Data/Hive/person.dart';
import 'package:weather/boxes.dart';

import '../../Bloc/TemperatureUnitsBloc/temperatureunit_bloc.dart';
import '../../Services/notification_service.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  Person person = boxPersons.getAt(0);
  @override
  Widget build(BuildContext context) {
    final TemperatureUnitBloc temperatureUnitBloc =
        BlocProvider.of<TemperatureUnitBloc>(context);
    return Scaffold(
      backgroundColor: const Color(0xfff7f7f7),
      appBar: AppBar(
        backgroundColor: Colors.deepOrangeAccent,
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios_rounded,
            color: Colors.white,
          ),
        ),
        title: Text(
          'Account',
          style: GoogleFonts.outfit(
            color: Colors.white,
          ),
        ),
      ),
      body: Column(
        children: [
          20.verticalSpace,
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 13.w,
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Hero(
                      tag: 'profile',
                      child: person.profileUrl == null
                          ? CircleAvatar(
                              radius: 45.r,
                              backgroundColor: Colors.white,
                              child: Icon(
                                Icons.person,
                                size: 45.r,
                                color: Colors.deepOrangeAccent,
                              ),
                            )
                          : Image.network(
                              person.profileUrl!,
                              width: 90.r,
                              height: 90.r,
                              fit: BoxFit.cover,
                            ),
                    ),
                    10.horizontalSpace,
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          person.name ?? "User",
                          style: GoogleFonts.outfit(
                            fontSize: 21.sp,
                            color: Colors.blueGrey.shade900,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          'Flutter Developer',
                          style: GoogleFonts.splineSans(
                            fontSize: 17.sp,
                            color: Colors.blueGrey.shade900,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                20.verticalSpace,
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      'Application',
                      style: GoogleFonts.outfit(
                        fontSize: 17.sp,
                        color: Colors.grey.shade900,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                5.verticalSpace,
                BlocBuilder<TemperatureUnitBloc, TemperatureUnitState>(
                  bloc: temperatureUnitBloc,
                  builder: (context, state) {
                    final isFahrenheit = state is TemperatureUnitFahrenheit;
                    return ListTile(
                      onTap: () {
                        context
                            .read<TemperatureUnitBloc>()
                            .add(TemperatureUnitToggleEvent());
                      },
                      leading: const Icon(
                        Icons.heat_pump_outlined,
                        color: Colors.deepOrangeAccent,
                      ),
                      title: Text(
                        'Unit - ${isFahrenheit ? 'Fahrenheit' : 'Celsius'}',
                        style: GoogleFonts.outfit(
                          fontSize: 14.sp,
                          color: Colors.blueGrey.shade900,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        'Change the temperature unit',
                        style: GoogleFonts.splineSans(
                          fontSize: 10.sp,
                          color: Colors.blueGrey.shade500,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      trailing: CupertinoSwitch(
                        value: state is TemperatureUnitFahrenheit,
                        onChanged: (newValue) {
                          context
                              .read<TemperatureUnitBloc>()
                              .add(TemperatureUnitToggleEvent());
                        },
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.notification_add,
                    color: Colors.deepOrangeAccent,
                  ),
                  title: Text(
                    'Test Notification',
                    style: GoogleFonts.outfit(
                      fontSize: 14.sp,
                      color: Colors.blueGrey.shade900,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    'Send a test notification',
                    style: GoogleFonts.splineSans(
                      fontSize: 10.sp,
                      color: Colors.blueGrey.shade500,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  trailing: IconButton(
                    onPressed: () {
                      NotificationService.sendNotification();
                    },
                    icon: const Icon(
                      Icons.notifications_active_rounded,
                      color: Colors.blueGrey,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () => _logout(context),
                  child: Container(
                      height: 50.h,
                      width: 100.h,
                      decoration: BoxDecoration(
                        color: Colors.redAccent.shade200,
                        borderRadius: BorderRadius.circular(18.r),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          const Icon(
                            Icons.logout_rounded,
                            color: Colors.white,
                          ),
                          Text(
                            "Logout",
                            style: GoogleFonts.splineSans(
                              fontSize: 15.sp,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          )
                        ],
                      )),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    BlocProvider.of<AuthBloc>(context).add(SignOutRequested());
    Navigator.pushNamedAndRemoveUntil(context, '/signin', (route) => false);
  }
}
