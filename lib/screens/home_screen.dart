import 'dart:developer';

import 'package:fixio/cubit/fixio_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // final TextEditingController _amountController = TextEditingController();
  // final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  dynamic _addBudget(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          final TextEditingController _amountController =
              TextEditingController();
          final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0), // Bordures arrondies
            ),
            child: Form(
              key: _formKey,
              child: Container(
                width: 300.w,
                height: 350.h,
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        spreadRadius: 5,
                        blurRadius: 10,
                      )
                    ]),
                child: Column(
                  children: [
                    Gap(50.h),
                    Text(
                      "Ajouter le budget de l'entreprise",
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Gap(50.h),
                    TextFormField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                          hintText: "Entrer le montant",
                          hintStyle: TextStyle(color: Colors.black54),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          )),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer une valeur';
                        }
                        final int? number = int.tryParse(value);
                        if (number == null) {
                          return 'Veuillez entrer un nombre valide';
                        }
                        if (number < 20000 || number > 10000000) {
                          return 'Le nombre doit être entre 5000 et 10000000';
                        }
                        return null; // Pas d'erreur
                      },
                    ),
                    Gap(30.h),
                    GestureDetector(
                        onTap: () {
                          if (_formKey.currentState!.validate()) {
                            setState(() {
                              context.read<FixioCubit>().saveBudget(
                                  double.parse(_amountController.text));
                            });
                            Navigator.of(context).pop();
                          }
                        },
                        child: Container(
                            width: double.infinity,
                            height: 50,
                            decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(20)),
                            child: Center(
                                child: Text(
                              "Ajouter",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: Colors.white),
                            ))))
                  ],
                ),
              ),
            ),
          );
        });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fixio - Accueil'),
      ),
      body: BlocBuilder<FixioCubit, double>(
        builder: (context, state) {
          return SingleChildScrollView(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Gap(60.h),

                  Text(
                    'Bienvenue sur Fixio',
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  Gap(30.h),
                  Text(
                    'Gérez vos dépenses de maintenance efficacement',
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  Gap(130.h),

                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Visibility(
                        visible: state != 0,
                        child: Text(
                          '${state} FCFA',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ),
                      Gap(120.h),
                    ],
                  ),
                  // Gap(40.h),
                  InkWell(
                      onTap: () => _addBudget(context),
                      child: Container(
                        width: 300.w,
                        height: 70.h,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                spreadRadius: 5,
                                blurRadius: 10,
                              ),
                            ]),
                        child: Center(child: Text('Ajouter le budget')),
                      )),

                  // const SizedBox(height: 90),
                  // if(state is )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
