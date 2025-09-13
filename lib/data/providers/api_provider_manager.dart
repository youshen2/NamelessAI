import 'package:flutter/material.dart';
import 'package:nameless_ai/data/app_database.dart';
import 'package:nameless_ai/data/models/api_provider.dart';
import 'package:nameless_ai/data/models/model.dart';

class APIProviderManager extends ChangeNotifier {
  List<APIProvider> _providers = [];
  APIProvider? _selectedProvider;
  Model? _selectedModel;

  APIProviderManager() {
    _loadProviders();
  }

  List<APIProvider> get providers => _providers;
  APIProvider? get selectedProvider => _selectedProvider;
  Model? get selectedModel => _selectedModel;

  List<Model> get availableModels => _selectedProvider?.models ?? [];

  void _loadProviders() {
    _providers = AppDatabase.apiProvidersBox.values.toList();
    if (_providers.isNotEmpty) {
      final lastProviderId =
          AppDatabase.appConfigBox.get('lastSelectedProviderId');
      final lastModelId = AppDatabase.appConfigBox.get('lastSelectedModelId');

      _selectedProvider = _providers.firstWhere(
        (p) => p.id == lastProviderId,
        orElse: () => _providers.first,
      );

      if (_selectedProvider != null && _selectedProvider!.models.isNotEmpty) {
        _selectedModel = _selectedProvider!.models.firstWhere(
          (m) => m.id == lastModelId,
          orElse: () => _selectedProvider!.models.first,
        );
      }
    }
    notifyListeners();
  }

  Future<void> addProvider(APIProvider provider) async {
    await AppDatabase.apiProvidersBox.put(provider.id, provider);
    _providers.add(provider);
    if (_selectedProvider == null) {
      setSelectedProvider(provider);
    }
    notifyListeners();
  }

  Future<void> updateProvider(APIProvider provider) async {
    await AppDatabase.apiProvidersBox.put(provider.id, provider);
    final index = _providers.indexWhere((p) => p.id == provider.id);
    if (index != -1) {
      _providers[index] = provider;
    }
    if (_selectedProvider?.id == provider.id) {
      _selectedProvider = provider;
      if (_selectedModel != null &&
          !provider.models.any((m) => m.id == _selectedModel!.id)) {
        _selectedModel =
            provider.models.isNotEmpty ? provider.models.first : null;
      }
    }
    notifyListeners();
  }

  Future<void> deleteProvider(String id) async {
    await AppDatabase.apiProvidersBox.delete(id);
    _providers.removeWhere((p) => p.id == id);
    if (_selectedProvider?.id == id) {
      _selectedProvider = _providers.isNotEmpty ? _providers.first : null;
      _selectedModel = _selectedProvider?.models.isNotEmpty == true
          ? _selectedProvider!.models.first
          : null;
    }
    _saveSelectedState();
    notifyListeners();
  }

  void setSelectedProvider(APIProvider? provider) {
    if (_selectedProvider != provider) {
      _selectedProvider = provider;
      _selectedModel =
          provider?.models.isNotEmpty == true ? provider!.models.first : null;
      _saveSelectedState();
      notifyListeners();
    }
  }

  void setSelectedModel(Model? model) {
    if (_selectedModel != model) {
      _selectedModel = model;
      _saveSelectedState();
      notifyListeners();
    }
  }

  void _saveSelectedState() {
    AppDatabase.appConfigBox
        .put('lastSelectedProviderId', _selectedProvider?.id);
    AppDatabase.appConfigBox.put('lastSelectedModelId', _selectedModel?.id);
  }
}
