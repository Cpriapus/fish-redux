import 'package:fish_redux/fish_redux.dart';
import 'package:flutter/widgets.dart' hide Action, Page;

import '../redux/redux.dart';
import 'basic.dart';

class _Dependent<T, P> implements Dependent<T> {
  final AbstractConnector<T, P> connector;
  final AbstractLogic<P> logic;
  final SubReducer<T> subReducer;

  _Dependent({
    @required this.logic,
    @required this.connector,
  })  : assert(logic != null),
        assert(connector != null),
        subReducer = logic.createReducer != null
            ? connector.subReducer(logic.createReducer())
            : null;

  @override
  SubReducer<T> createSubReducer() => subReducer;

  @override
  Widget buildComponent(
    Store<Object> store,
    Get<T> getter, {
    @required DispatchBus bus,
    @required Enhancer<Object> enhancer,
  }) {
    assert(bus != null && enhancer != null);
    assert(isComponent(), 'Unexpected type of ${logic.runtimeType}.');
    final AbstractComponent<P> component = logic;
    return component.buildComponent(
      store,
      () => connector.get(getter()),
      bus: bus,
      enhancer: enhancer,
    );
  }

  @override
  ListAdapter buildAdapter(covariant ContextSys<P> ctx) {
    assert(isAdapter(), 'Unexpected type of ${logic.runtimeType}.');
    final AbstractAdapter<P> adapter = logic;
    return adapter.buildAdapter(ctx);
  }

  @override
  Get<P> subGetter(Get<T> getter) => () => connector.get(getter());

  @override
  ContextSys<P> createContext(
    Store<Object> store,
    BuildContext buildContext,
    Get<T> getState, {
    @required DispatchBus bus,
    @required Enhancer<Object> enhancer,
  }) {
    assert(bus != null && enhancer != null);
    return logic.createContext(
      store,
      buildContext,
      subGetter(getState),
      bus: bus,
      enhancer: enhancer,
    );
  }

  @override
  bool isComponent() => logic is AbstractComponent;

  @override
  bool isAdapter() => logic is AbstractAdapter;

  @override
  Object key(T state) {
    return Tuple3<Type, Type, Object>(
      logic.runtimeType,
      connector.runtimeType,
      logic.key(connector.get(state)),
    );
  }
}

Dependent<K> createDependent<K, T>(
        AbstractConnector<K, T> connector, AbstractLogic<T> logic) =>
    logic != null ? _Dependent<K, T>(connector: connector, logic: logic) : null;
