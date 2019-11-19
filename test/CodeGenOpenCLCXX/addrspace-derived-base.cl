// RUN: %clang_cc1 %s -triple spir -cl-std=clc++ -emit-llvm -O0 -o - | FileCheck %s

struct B {
  int mb;
};

class D : public B {
public:
  int getmb() { return mb; }
};

void foo() {
  D d;
  //CHECK-LABEL: foo
  //CHECK: addrspacecast %class.D* %d to %class.D addrspace(4)*
  //CHECK: call spir_func i32 @_ZNU3AS41D5getmbEv(%class.D addrspace(4)*
  d.getmb();
}

//Derived and Base are in the same address space.

//CHECK: define linkonce_odr spir_func i32 @_ZNU3AS41D5getmbEv(%class.D addrspace(4)* %this)
//CHECK: bitcast %class.D addrspace(4)* %this1 to %struct.B addrspace(4)*


// Calling base method through multiple inheritance.

class B2 {
  public:
    void baseMethod() const {  }
    int bb;
};

class Derived : public B, public B2 {
  public:
    void work() const { baseMethod(); }
    // CHECK-LABEL: work
    // CHECK: bitcast i8 addrspace(4)* %add.ptr to %class.B2 addrspace(4)*
};

void pr43145(const Derived *argDerived) {
  argDerived->work();
}

// Casting from base to derived.

void pr43145_2(B *argB) {
  Derived *x = (Derived*)argB;
}

// CHECK-LABEL: @_Z9pr43145_2
// CHECK: bitcast %struct.B addrspace(4)* %0 to %class.Derived addrspace(4)*
