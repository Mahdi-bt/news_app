import 'package:app_1/layout/cubit/state.dart';
import 'package:app_1/models/newsModel.dart';
import 'package:app_1/modules/business/businessScreen.dart';
import 'package:app_1/modules/science/scienceScreen.dart';
import 'package:app_1/modules/sports/sportScreen.dart';
import 'package:app_1/shared/local/cache_Helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../shared/local/remote/dio_helper.dart';

class NewsCubit extends Cubit<NewsState> {
  NewsCubit() : super(NewsInitialState());

  static NewsCubit get(context) => BlocProvider.of(context);

  int currentIndex = 0;
  List<BottomNavigationBarItem> bottomItem = [
    const BottomNavigationBarItem(
        icon: Icon(
          Icons.business,
        ),
        label: 'Business'),
    const BottomNavigationBarItem(
        icon: Icon(
          Icons.sports,
        ),
        label: 'Sports'),
    const BottomNavigationBarItem(
      icon: Icon(
        Icons.science,
      ),
      label: 'science',
    ),
  ];

  void bottomChangeNavBar(int index) {
    currentIndex = index;
    if (index == 1) {
      getSports();
    }
    if (index == 2) {
      getScience();
    }
    emit(NewsBottomNavState());
  }

  List<Widget> Screns = [
    const BusinessScreen(),
    const SportsScreen(),
    const ScienceScreen(),
  ];

  BusinessModels? business;
  void getbusiness() async {
    emit(NewsGetBusinessLoadingState());
    await DioHelper.getData(
      url: 'v2/top-headlines',
      query: {
        'country': 'eg',
        'category': 'business',
        'apiKey': 'f7e6e96229574cf78cff4dde0ae82412',
      },
    ).then((value) {
      //print(value.data.toString());
      business = BusinessModels.fromJson(value.data);

      emit(NewsGetBusinessSuccessState());
    }).catchError((error) {
      emit(NewsGetBusinessErrorsState(error.toString()));
    });
  }

  List<dynamic> sports = [];
  void getSports() {
    emit(NewsGetSportsLoadingState());
    if (sports.isEmpty) {
      DioHelper.getData(
        url: 'v2/top-headlines',
        query: {
          'country': 'eg',
          'category': 'sports',
          'apiKey': 'f7e6e96229574cf78cff4dde0ae82412',
        },
      ).then((value) {
        //print(value.data.toString());
        sports = value.data['articles'];
        print(sports[0]['title']);
        emit(NewsGetSportsSuccessState());
      }).catchError((error) {
        print(error.toString());
        emit(NewsGetSportsErrorsState(error.toString()));
      });
    } else {
      emit(NewsGetSportsSuccessState());
    }
  }

  List<dynamic> science = [];
  void getScience() {
    emit(NewsGetScienceLoadingState());
    if (science.length == 0) {
      DioHelper.getData(
        url: 'v2/top-headlines',
        query: {
          'country': 'eg',
          'category': 'science',
          'apiKey': 'f7e6e96229574cf78cff4dde0ae82412',
        },
      ).then((value) {
        //print(value.data.toString());
        science = value.data['articles'];
        print(science[0]['title']);
        emit(NewsGetScienceSuccessState());
      }).catchError((error) {
        print(error.toString());
        emit(NewsGetScienceErrorsState(error.toString()));
      });
    } else {
      emit(NewsGetScienceSuccessState());
    }
  }

  bool isDark = true;
  initializeTheme({required bool theme}) {
    isDark = theme;
  }

  Future<void> changeAppMode() async {
    isDark = !isDark;
    print(isDark);
    CacheHelper.putData(
      key: 'isDark',
      value: isDark,
    ).then((value) {
      emit(AppChangeDarkModeState());
    });
  }

  List<Article> search = [];
  void getSearch(String value) {
    emit(NewsGetSearchLoadingState());
    search = [];

    DioHelper.getData(
      url: 'v2/everything',
      query: {
        'q': value,
        'apiKey': 'f7e6e96229574cf78cff4dde0ae82412',
      },
    ).then((value) {
      print(value.data['articles']);
      for (var element in value.data['articles']) {
        search.add(Article.fromJson(element));
      }
      emit(NewsGetSearchSuccessState());
    }).catchError((error) {
      print(error.toString());
      emit(NewsGetSearchErrorState((error.toString())));
    });
  }
}
