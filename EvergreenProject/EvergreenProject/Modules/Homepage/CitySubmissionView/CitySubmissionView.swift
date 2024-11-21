//
//  CitySubmissionView.swift
//  EvergreenProject
//
//  Created by Darul Firmansyah on 14/11/24.
//
import SwiftUI


struct CitySubmissionView: View {
    @ObservedObject var viewModel = CitySubmissionViewModel(apiClient: APIClient())
    var body: some View {
        List {
            if !viewModel.countries.isEmpty {
                ValuePicker("Country", selection: $viewModel.selectedCountry) {
                    ForEach(viewModel.countries) { country in
                        Text(verbatim: country.description)
                            .pickerTag(country)
                    }
                }
                .onChange(of: viewModel.selectedCountry) { _ in
                    viewModel.onCountryChanged()
                }
            }
            else if viewModel.isFetching {
                Text("Fetching Countries ...")
            }
            
            if !viewModel.states.isEmpty {
                ValuePicker("State", selection: $viewModel.selectedState) {
                    ForEach(viewModel.states) { state in
                        Text(verbatim: state.description)
                            .pickerTag(state)
                    }
                }
                .onChange(of: viewModel.selectedState) { _ in
                    viewModel.onStateChanged()
                }
            }
            else if viewModel.isFetching && viewModel.states.isEmpty {
                Text("Fetching States ...")
            }
            
            if !viewModel.cities.isEmpty {
                ValuePicker("City", selection: $viewModel.selectedCity) {
                    ForEach(viewModel.cities) { city in
                        Text(verbatim: city.description)
                            .pickerTag(city)
                    }
                }
                .onChange(of: viewModel.selectedCity) { _ in
                    viewModel.onCityChanged()
                }
            }
            else if viewModel.isFetching && viewModel.cities.isEmpty {
                Text("Fetching City ...")
            }
        }
        .navigationTitle("Add your city")
    }
}

class Pickable: NSObject, Identifiable {
    override var description: String { label }
    var id: String { label }
    let label: String
    
    init(label: String) {
        self.label = label
    }
}

public struct ValuePicker<SelectionValue: Hashable, Content: View>: View {
  private let title: LocalizedStringKey
  private let selection: Binding<SelectionValue>
  private let content: Content

  public init(
    _ title: LocalizedStringKey,
    selection: Binding<SelectionValue>,
    @ViewBuilder content: () -> Content
  ) {
    self.title = title
    self.selection = selection
    self.content = content()
  }

  public var body: some View {
    NavigationLink {
      List {
        _VariadicView.Tree(ValuePickerOptions(selectedValue: selection)) {
          content
        }
      }
      .navigationTitle(title)
    } label: {
      VStack {
        Text(title)
          .font(.footnote.weight(.medium))
          .foregroundStyle(.secondary)

        Text(verbatim: String(describing: selection.wrappedValue))
      }
    }
  }
}

private struct ValuePickerOptions<Value: Hashable>: _VariadicView.MultiViewRoot {
  private let selectedValue: Binding<Value>

  init(selectedValue: Binding<Value>) {
    self.selectedValue = selectedValue
  }

  @ViewBuilder
  func body(children: _VariadicView.Children) -> some View {
    Section {
      ForEach(children) { child in
        ValuePickerOption(
          selectedValue: selectedValue,
          value: child[CustomTagValueTraitKey<Value>.self]
        ) {
          child
        }
      }
    }
  }
}

private struct ValuePickerOption<Content: View, Value: Hashable>: View {
  @Environment(\.dismiss) private var dismiss

  private let selectedValue: Binding<Value>
  private let value: Value?
  private let content: Content

  init(
    selectedValue: Binding<Value>,
    value: CustomTagValueTraitKey<Value>.Value,
    @ViewBuilder _ content: () -> Content
  ) {
    self.selectedValue = selectedValue
    self.value = if case .tagged(let tag) = value {
      tag
    } else {
      nil
    }
    self.content = content()
  }

  var body: some View {
    Button(
      action: {
        if let value {
          selectedValue.wrappedValue = value
        }
        dismiss()
      },
      label: {
        HStack {
          content
            .tint(.primary)
            .frame(maxWidth: .infinity, alignment: .leading)

          if isSelected {
            Image(systemName: "checkmark")
              .foregroundStyle(.tint)
              .font(.body.weight(.semibold))
              .accessibilityHidden(true)
          }
        }
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
      }
    )
  }

  private var isSelected: Bool {
    selectedValue.wrappedValue == value
  }
}

extension View {
  public func pickerTag<V: Hashable>(_ tag: V) -> some View {
    _trait(CustomTagValueTraitKey<V>.self, .tagged(tag))
  }
}

private struct CustomTagValueTraitKey<V: Hashable>: _ViewTraitKey {
  enum Value {
    case untagged
    case tagged(V)
  }

  static var defaultValue: CustomTagValueTraitKey<V>.Value {
    .untagged
  }
}
