
import 'package:equatable/equatable.dart';

abstract class TreeNode<T> with EquatableMixin {

  T item;
  List<TreeNode<T>> childrenItems;

  TreeNode(this.item, this.childrenItems);

  @override
  List<Object?> get props => [item, childrenItems];
}