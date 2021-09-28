import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart' as ph;
import 'package:stacked/stacked.dart';
import '../../../../src/core/models/box_collection.dart';
import '../../../../src/core/models/collection.dart';
import '../../../../src/core/models/counter_collection.dart';
import '../../../../src/core/models/machine.dart';
import '../../../../src/core/providers/collections_provider.dart';
import '../../../../src/core/providers/counter_types_provider.dart';
import '../../../../src/core/providers/machines_provider.dart';
import '../../../../src/core/providers/user_provider.dart';
import '../../../../src/core/services/api_service.dart';
import '../../../../src/core/services/interface_service.dart';
import '../../../../src/interface/pages/edit_collection/widgets.dart';
import '../../../../src/interface/shared/colors.dart';
import '../../../../src/interface/shared/error_translator.dart';

import '../../../core/models/box_collection.dart';
import '../../../core/models/collection.dart';
import '../../../core/models/counter_collection.dart';
import '../../../core/models/machine.dart';
import '../../../core/providers/collections_provider.dart';
import '../../../core/providers/counter_types_provider.dart';
import '../../../core/providers/machines_provider.dart';
import '../../../core/providers/user_provider.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/interface_service.dart';
import '../../../locator.dart';
import '../../shared/colors.dart';
import '../../shared/error_translator.dart';
import 'widgets.dart';

class EditCollectionPageModel extends BaseViewModel {
  Machine _machine;
  Machine get machine => _machine;
  final counterTypesProvider = locator<CounterTypesProvider>();
  final collectionsProvider = locator<CollectionsProvider>();
  final interfaceService = locator<InterfaceService>();
  final userProvider = locator<UserProvider>();
  final colors = locator<AppColors>();
  Collection collection = Collection();
  List<String> photosToDelete = [];
  bool creatingCollection;
  Location location = Location();
  bool _locationServiceEnabled;
  PermissionStatus _permissionGranted;
  LocationData startLocation;
  LocationData endLocation;
  DateTime startTime;
  List<CameraDescription> cameras;
  CameraController cameraController;

  Future checkLocationPermissions() async {
    _locationServiceEnabled = await location.serviceEnabled();
    if (!_locationServiceEnabled) {
      _locationServiceEnabled = await location.requestService();
      if (!_locationServiceEnabled) {
        interfaceService.goBack();
      }
    }
    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        interfaceService.goBack();
      }
    }
    startTime = DateTime.now();
  }

  void initializeCreateCollection() async {
    setBusy(true);
    interfaceService.showLoader();
    await checkLocationPermissions();
    await ph.Permission.manageExternalStorage.request();
    await ph.Permission.storage.request();
    cameras = await availableCameras();
    cameraController = CameraController(
      cameras[0],
      ResolutionPreset.max,
    );
    await cameraController.initialize();
    cameraController.setZoomLevel(0);

    cameraController.setFocusPoint(Offset(100, 100));
    cameraController.setFocusMode(FocusMode.auto);
    startLocation = await location.getLocation();
    await counterTypesProvider.getAllCounterTypes();
    collection.machineId = _machine.id;
    await initializeEmptyListsOfCounters();

    interfaceService.closeLoader();
    setBusy(false);
  }

  void initializeEditCollection() async {
    setBusy(true);
    interfaceService.showLoader();
    await counterTypesProvider.getAllCounterTypes();
    cameras = await availableCameras();
    cameraController = CameraController(
      cameras[0],
      ResolutionPreset.max,
    );
    await cameraController.initialize();
    cameraController.setZoomLevel(0);

    cameraController.setFocusPoint(Offset(100, 100));
    cameraController.setFocusMode(FocusMode.auto);
    initializeListsOfCounters();
    interfaceService.closeLoader();
    setBusy(false);
  }

  set machine(value) => _machine = value;

  List<dynamic> digitalCounters = [];
  List<dynamic> mechanicalCounters = [];
  List<dynamic> countedCounters = [];
  List<dynamic> totalCounters = [];
  var filesPerCounter = [];

  void initializeListsOfCounters() {
    for (var i = 0; i < collection.boxCollections.length; i++) {
      for (var z = 0;
          z < collection.boxCollections[i].counterCollections.length;
          z++) {
        var counterCollection =
            collection.boxCollections[i].counterCollections[z];
        var counterTypeId =
            collection.machine.boxes[i].counters[z].counterTypeId;
        counterCollection.counterTypeId = counterTypeId;
        var counterTypeLabel = counterTypesProvider.counterTypes
            .firstWhere((element) => element.id == counterTypeId)
            .label;
        counterCollection.counterTypeLabel = counterTypeLabel;
        totalCounters
            .add({'box': ' - Cabine ${i + 1}', 'counter': counterCollection});
        if (counterCollection.digitalCount != null) {
          digitalCounters
              .add({'box': ' - Cabine ${i + 1}', 'counter': counterCollection});
        }
        if (counterCollection.mechanicalCount != null) {
          mechanicalCounters
              .add({'box': ' - Cabine ${i + 1}', 'counter': counterCollection});
        }
        if (counterCollection.userCount != null) {
          countedCounters
              .add({'box': ' - Cabine ${i + 1}', 'counter': counterCollection});
        }
      }
    }
    totalCounters.forEach((element) {
      var existingPhotos = [...element['counter'].photos];
      filesPerCounter.add(existingPhotos);
    });
  }

  Future initializeEmptyListsOfCounters() async {
    for (var i = 0; i < machine.boxes.length; i++) {
      var temp = BoxCollection(machine.boxes[i].id);
      machine.boxes[i].counters.forEach((counter) {
        var counterTypeLabel = counterTypesProvider.counterTypes
            .firstWhere((element) => element.id == counter.counterTypeId)
            .label;
        temp.counterCollections.add(
          CounterCollection(
            counter.id,
            counter.hasDigital,
            counter.hasMechanical,
            (counterTypeLabel == 'Noteiro' || counterTypeLabel == 'Moedeiro'),
            counterTypeLabel,
          ),
        );
        totalCounters.add({'box': ' - Cabine ${i + 1}', 'counter': counter});
        if (counter.hasDigital) {
          digitalCounters
              .add({'box': ' - Cabine ${i + 1}', 'counter': counter});
        }
        if (counter.hasMechanical) {
          mechanicalCounters
              .add({'box': ' - Cabine ${i + 1}', 'counter': counter});
        }
        if (counterTypeLabel == 'Noteiro' || counterTypeLabel == 'Moedeiro') {
          countedCounters
              .add({'box': ' - Cabine ${i + 1}', 'counter': counter});
        }
      });
      collection.boxCollections.add(temp);
    }
    totalCounters.forEach((element) {
      filesPerCounter.add([]);
    });
  }

  void popSourceOfFileDialog(index, context) async {
    await interfaceService.showModal(
      widget: CollectionCamera(
        cameraController: cameraController,
        onTap: () async {
          interfaceService.showLoader();
          final image = await cameraController.takePicture();
          var file = File(image.path);
          final filePath = file.absolute.path;
          final lastIndex = filePath.lastIndexOf(RegExp(r'.jp'));
          final splitted = filePath.substring(0, lastIndex);
          final outPath = '${splitted}_out${filePath.substring(lastIndex)}';
          var quality = 30;
          var result = File(file.path);
          while (result.lengthSync() > 800000) {
            result = await FlutterImageCompress.compressAndGetFile(
              file.absolute.path,
              outPath,
              quality: quality,
            );
            quality -= 10;
          }
          filesPerCounter[index].insert(0, result);
          collection.boxCollections.forEach((boxC) {
            boxC.counterCollections.forEach((counterC) {
              try {
                if (totalCounters[index]['counter'].id == counterC.counterId) {
                  counterC.photos.insert(0, result);
                }
              } catch (e) {
                if (totalCounters[index]['counter'].counterId ==
                    counterC.counterId) {
                  counterC.photos.insert(0, result);
                }
              }
            });
          });
          interfaceService.closeLoader();
          interfaceService.goBack();
          notifyListeners();
        },
      ),
    );
    // imgFromCamera(index);
    // await interfaceService.showDialogMessage(
    //   title: 'Adicionar foto',
    //   message: 'De onde deseja obter a foto?',
    //   actions: [
    //     DialogAction(
    //       title: 'Galeria',
    //       onPressed: () {
    //         interfaceService.goBack();
    //         imgFromGallery(index);
    //       },
    //     ),
    //     DialogAction(
    //       title: 'Câmera',
    //       onPressed: () {
    //         interfaceService.goBack();
    //         // openCamera(context, index);
    //         imgFromCamera(index);
    //       },
    //     ),
    //   ],
    // );
  }

  //PACKAGE IMAGE PICKER
  // void imgFromCamera(index) async {
  //   var image = await ImagePicker().getImage(
  //     source: ImageSource.camera,
  //     imageQuality: 30,
  //     preferredCameraDevice: CameraDevice.rear,
  //   );
  //   var file = File(image.path);
  //   final filePath = file.absolute.path;
  //   final lastIndex = filePath.lastIndexOf(RegExp(r'.jp'));
  //   final splitted = filePath.substring(0, lastIndex);
  //   final outPath = '${splitted}_out${filePath.substring(lastIndex)}';
  //   var quality = 20;
  //   var result = file;
  //   while (result.lengthSync() > 200000) {
  //     result = await FlutterImageCompress.compressAndGetFile(
  //       file.absolute.path,
  //       outPath,
  //       quality: quality,
  //     );
  //     quality -= 10;
  //   }
  //   await file.delete();
  //   filesPerCounter[index].insert(0, result);
  //   collection.boxCollections.forEach((boxC) {
  //     boxC.counterCollections.forEach((counterC) {
  //       try {
  //         if (totalCounters[index]['counter'].id == counterC.counterId) {
  //           counterC.photos.insert(0, result);
  //         }
  //       } catch (e) {
  //         if (totalCounters[index]['counter'].counterId == counterC.counterId) {
  //           counterC.photos.insert(0, result);
  //         }
  //       }
  //     });
  //   });
  //   notifyListeners();
  // }

  void addToDigitalCounter(String cId, String amount) {
    collection.boxCollections.forEach((boxCollection) {
      boxCollection.counterCollections.forEach((counterCollection) {
        if (counterCollection.counterId == cId) {
          counterCollection.digitalCount = double.parse(amount);
        }
      });
    });
  }

  void addToMechanicalCounter(String cId, String amount) {
    collection.boxCollections.forEach((boxCollection) {
      boxCollection.counterCollections.forEach((counterCollection) {
        if (counterCollection.counterId == cId) {
          counterCollection.mechanicalCount = double.parse(amount);
        }
      });
    });
  }

  void addToCountedMechanical(String cId, String amount) {
    collection.boxCollections.forEach((boxCollection) {
      boxCollection.counterCollections.forEach((counterCollection) {
        if (counterCollection.counterId == cId) {
          counterCollection.userCount = double.parse(amount);
        }
      });
    });
  }

  void removeAt(index, photoIndex) {
    filesPerCounter[index].removeAt(photoIndex);
    collection.boxCollections.forEach((boxC) {
      boxC.counterCollections.forEach((counterC) {
        try {
          if (totalCounters[index]['counter'].id == counterC.counterId) {
            if (counterC.photos[photoIndex].runtimeType == CounterPhoto) {
              photosToDelete.add(counterC.photos[photoIndex].key);
            }
            counterC.photos.removeAt(photoIndex);
          }
        } catch (e) {
          if (totalCounters[index]['counter'].counterId == counterC.counterId) {
            if (counterC.photos[photoIndex].runtimeType == CounterPhoto) {
              photosToDelete.add(counterC.photos[photoIndex].key);
            }
            counterC.photos.removeAt(photoIndex);
          }
        }
      });
    });
    notifyListeners();
  }

  void fillObservations(String value) {
    if (value == '') {
      collection.observations = null;
    } else {
      collection.observations = value;
    }
  }

  void imgFromGallery(index) async {
    var image = await ImagePicker().getImage(source: ImageSource.gallery);
    var file = File(image.path);
    final filePath = file.absolute.path;
    final lastIndex = filePath.lastIndexOf(RegExp(r'.jp'));
    final splitted = filePath.substring(0, lastIndex);
    final outPath = '${splitted}_out${filePath.substring(lastIndex)}';
    var quality = 50;
    var result = file;
    while (result.lengthSync() > 200000) {
      result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        outPath,
        quality: quality,
      );
      quality -= 5;
    }
    await file.delete();
    filesPerCounter[index].insert(0, result);
    collection.boxCollections.forEach((boxC) {
      boxC.counterCollections.forEach((counterC) {
        try {
          if (totalCounters[index]['counter'].id == counterC.counterId) {
            counterC.photos.insert(0, result);
          }
        } catch (e) {
          if (totalCounters[index]['counter'].counterId == counterC.counterId) {
            counterC.photos.insert(0, result);
          }
        }
      });
    });
    notifyListeners();
  }

  bool validateFields(bool editing) {
    var data = collection.toMap(editing);
    var validated;
    if (data['observations'] == null) {
      interfaceService.showSnackBar(
          message: 'O campo de observações é obrigatório.',
          backgroundColor: colors.red);
      validated = false;
    }
    if (validated == null) return true;
    return false;
  }

  void editCollection() async {
    var request = http.MultipartRequest(
      'PUT',
      Uri.parse(
          '${ApiService.baseUrl}${ApiRoutes().collections}/${collection.id}'),
    );
    if (validateFields(true)) {
      interfaceService.showLoader();
      var data = collection.toMap(true);
      if (photosToDelete != null) {
        request.fields['photosToDelete'] = json.encode(photosToDelete);
      }
      request.fields['machineId'] = data['machineId'];
      request.fields['observations'] = data['observations'];
      request.fields['boxCollections'] = json.encode(data['boxCollections']);
      await Future.forEach(
        collection.boxCollections,
        (boxCollection) async => await Future.forEach(
          boxCollection.counterCollections,
          (counterCollection) async => await Future.forEach(
            counterCollection.photos,
            (file) async {
              if (file is File) {
                request.files.add(
                  await http.MultipartFile.fromPath(
                    '${boxCollection.boxId}:${counterCollection.counterId}',
                    file.path,
                  ),
                );
              }
            },
          ),
        ),
      );
      request.headers.addAll(ApiService.baseHeaders);
      await request.send().then((http.StreamedResponse response) async {
        var body = await response.stream.bytesToString();
        if (response.statusCode == 200) {
          collectionsProvider.addToFilteredCollections(json.decode(body));
          collectionsProvider
              .updateDetailedCollection(Collection.fromMap(json.decode(body)));
          filesPerCounter.forEach((element) {
            element.forEach((e) {
              if (e is File) {
                e.delete();
              }
            });
          });
          await locator<MachinesProvider>()
              .getDetailedMachine(collection.machine.id, 'DAILY');
          interfaceService.showSnackBar(
            message: 'Coleta editada com sucesso.',
            backgroundColor: colors.lightGreen,
          );
          interfaceService.goBack();
        } else {
          interfaceService.showSnackBar(
            message: translateError(body),
            backgroundColor: colors.red,
          );
        }
      });
      interfaceService.closeLoader();
    }
  }

  void createCollection() async {
    var request = http.MultipartRequest(
        'POST', Uri.parse('${ApiService.baseUrl}${ApiRoutes().collections}'));
    if (validateFields(false)) {
      interfaceService.showLoader();
      endLocation = await location.getLocation();
      var data = collection.toMap(false);
      if (startLocation != null) {
        data['startLocation'] = {
          'latitude': startLocation.latitude,
          'longitude': startLocation.longitude
        };
        request.fields['startLocation'] = json.encode(data['startLocation']);
      }
      if (endLocation != null) {
        data['endLocation'] = {
          'latitude': endLocation.latitude,
          'longitude': endLocation.longitude
        };
        request.fields['endLocation'] = json.encode(data['endLocation']);
      }
      request.fields['startTime'] = startTime.toUtc().toIso8601String();
      request.fields['machineId'] = data['machineId'];
      request.fields['observations'] = data['observations'];
      request.fields['boxCollections'] = json.encode(data['boxCollections']);
      await Future.forEach(
        collection.boxCollections,
        (boxCollection) async => await Future.forEach(
          boxCollection.counterCollections,
          (counterCollection) async => await Future.forEach(
            counterCollection.photos,
            (file) async {
              request.files.add(
                await http.MultipartFile.fromPath(
                  '${boxCollection.boxId}:${counterCollection.counterId}',
                  file.path,
                ),
              );
            },
          ),
        ),
      );
      request.headers.addAll(ApiService.baseHeaders);
      await request.send().then((http.StreamedResponse response) async {
        var body = await response.stream.bytesToString();
        if (response.statusCode == 201) {
          collectionsProvider.addToFilteredCollections(json.decode(body));
          filesPerCounter.forEach((element) {
            element.forEach((e) {
              if (e is File) {
                e.delete();
              }
            });
          });
          interfaceService.goBack();
          interfaceService.showSnackBar(
            message: 'Coleta criada com sucesso.',
            backgroundColor: colors.lightGreen,
          );
          await locator<MachinesProvider>()
              .getDetailedMachine(_machine.id, 'DAILY');
        } else {
          interfaceService.showSnackBar(
            message: translateError(body),
            backgroundColor: colors.red,
          );
        }
      });
      interfaceService.closeLoader();
    }
  }

  @override
  void dispose() {
    cameraController.dispose();
    filesPerCounter.forEach((element) {
      element.forEach((e) {
        if (e is File) {
          e.delete();
        }
      });
    });
    collection.boxCollections.forEach((bc) {
      bc.counterCollections.forEach((cc) {
        cc.photos.forEach((photo) {
          if (photo is File) {
            photo.delete();
          }
        });
      });
    });
    super.dispose();
  }
}
