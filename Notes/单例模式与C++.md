# 单例模式

设计软件的时候，有时候为了得到良好的执行效率且逻辑正确，在整个软件中有些类只能被实例化一次。举个栗子，Windows系统的任务管理器就只能打开一个，还有一个系统里面的线程池、配置文件读取的实例等等。

最直接接触单例模式是在学校跟老师开发软件的时候，基本全是单例，当时还不懂这是什么，就觉得这样写好帅啊（哈哈哈哈有点傻），在实现分配给自己的模块的时候，就照着写了。回过头来稍微了解了一些。

## 1. 简述

单例模式就是系统里一个类只有一个实例，其他任何实例或线程想调用该类的方法时，访问的都是同一个实例。

单例模式主要分为懒汉式与饿汉式。顾名思义，懒汉的含义是——“懒得”对一个类进行实例化，当系统第一次想访问类的某个方法时，才对该类进行实例化，然后后面再调用方法的时候就不需要先实例化一个对象出来了；饿汉就是恨不得在系统初始化的时候把所有类都先实例化一个对象出来，因为它“饿”啊。

## 2. 懒汉式

懒汉的思想上面已经提了，接下来主要是实现

```c++
class singleton_Lazy {
public:
    static singleton_Lazy *instance(); ///< 外部函数通过本函数获得类的实例

private:
    singleton_Lazy() {
        // 构造函数放在private里，防止外部函数随意实例化
    }
    static singleton_Lazy *pointer; ///< 本类唯一的实例
};

singleton_Lazy *singleton_Lazy::pointer = nullptr;

singleton_Lazy *singleton_Lazy::instance() {
    // 检查有没有被实例化，有则直接返回唯一的实例，没有就new一个
    if (pointer == nullptr) pointer = new singleton_Lazy(); 
    return pointer;
}
```

外部函数在调用该类方法的时候，都需要写成`singleton_Lazy::instance()->method()`。

但是这样的写法存在问题，具体是在多线程环境下，假设有两个线程同时调用`instance()`，那么它们可能在检查`pointer == nullptr`的时候都发现为真，就都会`new`一个新的实例给`pointer`。那么这两个线程能使用的是同一个对象，也可能是两个对象，这样就可能导致程序错误，同时，还会发生内存泄漏。

总之，这样写是线程不安全的，安全版本在后面。

## 3. 饿汉式

饿汉式和懒汉式主要区别就体现在类在定义的时候就进行实例化。

```c++
class singleton {
public:
    static singleton *instance();

private:
    singleton() {
        // some codes
    }
    static singleton *pointer;
};

singleton *singleton::pointer = new singleton(); ///< 定义的时候就被实例化

singleton *singleton::instance() {
    return pointer;
}
```

调用方式与懒汉相同。饿汉式是线程安全的。

## 4. 懒汉式-修改

### 4.1 内存泄漏

出现这种问题主要是因为`new`出来一个对象始终没有释放。

```c++
class singleton_Lazy {
public:
    static singleton_Lazy *instance();

private:
    singleton_Lazy() {
        // some codes
    }
    static singleton_Lazy *pointer;

    class releasePointer { // 内部定义一个嵌套类，专门用来释放静态成员pointer
    public:
        ~releasePointer() {
            if (singleton_Lazy::pointer) delete pointer;
        }
    };
    static releasePointer releaseP; ///< 嵌套类的实例化对象，单例的静态成员变量
};

singleton_Lazy *singleton_Lazy::pointer = nullptr;

singleton_Lazy *singleton_Lazy::instance() {
    if (pointer == nullptr) pointer = new singleton_Lazy();
    return pointer;
}
```

在程序结束时，系统会自动析构全局变量，从而调用嵌套类的析构函数，进而释放单例对象。

### 4.2 线程安全

这个问题在开始已经提过，在懒汉式遇到多线程的时候会发生线程不安全。

```c++
class singleton_Lazy {
public:
    static singleton_Lazy *instance();

private:
    singleton_Lazy() {
        // some codes
    }
    static singleton_Lazy *pointer;
    static std::mutex _mu; ///< 设置互斥量
};

singleton_Lazy *singleton_Lazy::pointer = nullptr;

singleton_Lazy *singleton_Lazy::instance() {
    std::lock_guard<std::mutex> guard(_mu); ///< 获取mutex权限，在函数结束后可以自动释放权限
    if (pointer == nullptr) pointer = new singleton_Lazy();
    return pointer;
}
```

在`instance()`方法里加一个互斥量访问，当两个线程同时进入到`instance()`方法里时，另一个线程一定会被阻塞在加锁处，直到前一个线程完成实例化后释放互斥量。这样是线程安全的。

或者用`_mu.lock()`和`_mu.unlock()`也可以，需要手动管理加解锁，不如`lock_guard`方便。

但是这种方法同样存在问题，即每次有外部函数调用该类的方法时，都需要经过`instance()`，也就都需要对互斥量进行访问，进行加解锁。实际上，只有第一次访问的时候，需要锁机制对`new singleton_lazy()`保护，其余的时候是不必要的，通过判断实例已经创建就直接返回即可。所以这种加锁方式会产生性能问题。

### 4.3 双重检查锁（DCL）

基于上一节里提出的性能问题，系统只需要在第一次访问`instance()`函数的时候加解锁，其余时候不需要，可以用DCLP（Double-Check-Locking-Pattern）。

```c++
class singleton_Lazy {
public:
    static singleton_Lazy *instance();

private:
    singleton_Lazy() {
        // some codes
    }
    static singleton_Lazy *pointer;
    static std::mutex _mu;
};

singleton_Lazy *singleton_Lazy::pointer = nullptr;

singleton_Lazy *singleton_Lazy::instance() {
    if (pointer == nullptr) { // 第一重检查
        std::lock_guard<std::mutex> guard(_mu);
        if (pointer == nullptr) {
            pointer = new singleton_Lazy();
        }
    }
    return pointer;
}
```

第一重检查的意义在于：大部分调用`instance()`的时候都会发现`pointer`非空，就不会尝试加解锁和初始化，直接返回唯一实例；而只有第一次调用`instance()`的时候再进行加解锁，然后`new`一个实例。

第二重检查的意义在于：在开始的时候同时有两个线程访问`instance()`时，第一重检查他们都能通过，但加锁之后就变成了上一节所提的情形，保证了线程是安全的。

但是但是但是，这种方法又出现了新的问题：内存读写的乱序执行问题，这事编译器的锅。编译器本意是好的，优化代码以提高执行效率，但是乱序执行技术导致实例化对象的过程不是我们预想的顺序。

像是初始化对象的语句:

```c++
pointer = new singleton_Lazy();
```

正常情况下，预想的顺序是：

1. 分配内存用来存储`singleton_Lazy`的对象；
2. 构造一个`singleton_Lazy`的对象在分配的内存上；
3. 让`pointer`指向这段内存。

实际上因为乱序技术，步骤`1`是最先执行，`2`、`3`却不一定按照顺序：

- 线程A调用`instance()`，检查`pointer`为空，需要初始化，上锁，再检查，初始化 -> CPU执行`1`分配内存，然后执行`3`让`pointer`指向这段内存，然后CPU把这个线程挂起了！
- 此时正好线程B调用`instance()`，在第一重检查的时候发现`pointer`不为空了，于是直接返回给了调用者，调用者再对指针解引用，发现指针指向的内存里对象还没有构造出来，问题就出现了！

仅当步骤`1`、`2`和`3`按顺序被执行，DCLP才能够良好的工作，所以在此基础上要加上限制顺序的语法。

### 4.4 C++ 11 以前解决乱序执行

***（这一节的代码为搬运，暂时没有深入研究）***

#### 4.4.1 内存屏障

为了消除乱序执行的消极影响，处理器允许程序员显式的告诉自己对某些地方禁止乱序执行，这种机制就是所谓内存屏障。

在C++ 11以前需要显式地加内存屏障，强迫CPU按序执行。



```c++
// 第一种实现：
// 基于operator new+placement new，遵循1,2,3执行顺序依次编写代码。
// method 1 operator new + placement new
singleton *instance() {
    if (p == nullptr) {
        lock_guard<mutex> guard(lock_);
        if (p == nullptr) {
            singleton *tmp = static_cast<singleton *>(operator new(sizeof(singleton)));
            new(p)singleton();
            p = tmp;
        }
    }
    return p;
}
```

```c++
// 第二种实现：
// 基于直接嵌入ASM汇编指令mfence，uninx的barrier宏也是通过该指令实现的。

#define barrier() __asm__ volatile ("lwsync")
singleton *singleton::instance() {
    if (p == nullptr) {
        lock_guard<mutex> guard(lock_);
        barrier();
        if (p == nullptr) {
            p = new singleton();
        }
    }
    return p;
}
// 通常情况下是调用cpu提供的一条指令，
// 这条指令的作用是会阻止cpu将该指令之前的指令交换到该指令之后，这条指令也通常被叫做barrier。
// 上面代码中的asm表示这个是一条汇编指令，volatile是可选的，
// 如果用了它，则表示向编译器声明不允许对该汇编指令进行优化。
// lwsync是POWERPC提供的barrier指令。
```

#### 4.4.2 pthread_once

如果是在unix平台的话，除了使用atomic operation外，在不适用C++11的情况下，还可以通过pthread_once来实现Singleton。

原型如下：

```c++
int pthread_once(pthread_once_t once_control, void (init_routine) (void))；
```

实现：

```c++
class singleton {
private:
    singleton(); //私有构造函数，不允许使用者自己生成对象
    singleton(const singleton &other);

    //要写成静态方法的原因：类成员函数隐含传递this指针（第一个参数）
    static void init() {
        p = new singleton();
    }

    static pthread_once_t ponce_;
    static singleton *p; //静态成员变量 
public:
    singleton *instance() {
        // init函数只会执行一次
        pthread_once(&ponce_, &singleton::init);
        return p;
    }
};
```

### 4.5 C++ 11 以后解决乱序和线程安全

在C++11之前的版本下，除了通过锁实现线程安全的Singleton外，还可以利用各个编译器内置的atomic operation来实现。

java和c#发现乱序问题后，就加了一个关键字volatile，在声明`p`变量的时候，要加上`volatile`修饰，编译器看到之后，就知道这个地方不能够reorder（一定要先分配内存，在执行构造器，都完成之后再赋值）。

而对于c++标准却一直没有改正，所以VC++在2005版本也加入了这个关键字，但是这并不能够跨平台（只支持微软平台）。

值得注意的是，C++和Java里的volatile有不同之处：

- 在C++里，Volatile关键字能够保证变量间的顺序性，编译器不会进行乱序优化。即便杜绝了编译器的乱序优化，但是针对生成的汇编代码，CPU有可能仍旧会乱序执行指令。
- Java里Volatile关键字与C++相似，但最大的不同在于：Java Volatile变量的操作，附带了Acquire与Release语义。通过Java Volatile的Acquire、Release语义，对比C/C++ Volatile，可以看出，Java Volatile对于编译器、CPU的乱序优化，限制的更加严格了。Java Volatile变量与非Volatile变量的一些乱序操作，也同样被禁止。

#### 4.5.1 Atomic

C++ 11 及之后版本，为了从根本上消除这些漏洞，引入了适合多线程的内存模型。


```c++
mutex singleton::lock_;
atomic<singleton *> singleton::p;

// std::atomic_thread_fence(std::memory_order_acquire); 
// std::atomic_thread_fence(std::memory_order_release);
// 这两句话可以保证他们之间的语句不会发生乱序执行。
singleton *singleton::instance() {
    singleton *tmp = p.load(memory_order_relaxed);
    atomic_thread_fence(memory_order_acquire);
    if (tmp == nullptr) {
        lock_guard<mutex> guard(lock_);
        tmp = p.load(memory_order_relaxed);
        if (tmp == nullptr) {
            tmp = new singleton();
            atomic_thread_fence(memory_order_release);
            p.store(tmp, memory_order_relaxed);
        }
    }
    return p;
}
```

对于内存的写操作，带有Release语义，当前线程本次写操作之前的其他任何读写操作，都不会被编译器、CPU优化后，乱序到本次写操作之后执行。

对于内存的的读操作，带有Acquire语义，当前线程本次读操作之后的其他任何读写操作，都不会被编译器、CPU优化后，乱序到本次读操作之前进行。

acquire 和 release 通常都是配对出现的，目的是保证如果对同一个原子对象的 release 发生在 acquire 之前的话，release 之前发生的内存修改能够被 acquire 之后的内存读取全部看到。

（可以参看上一节，Java的volatile关键字包涵了这部分功能，所以说比C++的volatile关键字更加严格）

#### 4.5.2 静态局部变量

在《Effective C++》里有一种写法

```c++
singleton *singleton::instance() {
    static singleton p;
    return &p;
}
```

这种写法适用于C++ 11 以后的单线程和多线程编程，原因是新的标准里规定：当一个线程正在初始化一个变量的时候，其他线程必须得等到该初始化完成以后才能访问它。

使用的内存序即是上小节提到的：

- memory_order_relaxed：松散内存序，只用来保证对原子对象的操作是原子的
- memory_order_acquire：获得操作，在读取某原子对象时，当前线程的任何后面的读写操作都不允许重排到这个操作的前面去，并且其他线程在对同一个原子对象释放之前的所有内存写入都在当前线程可见
- memory_order_release：释放操作，在写入某原子对象时，当前线程的任何前面的读写操作都不允许重排到这个操作的后面去，并且当前线程的所有内存写入都在对同一个原子对象进行获取的其他线程可见

### 4.6 懒汉式终极版本

结合C++ 11 的新特性，使用局部静态变量初始化单例，配合智能指针实现对对象的构建和自动析构。

```c++
class singleton {
public:
    static std::shared_ptr<singleton> getInstance();

private:
    singleton() {
        // some codes
    }
};

std::shared_ptr<singleton> singleton::getInstance() {
    static auto instance = std::shared_ptr<singleton>(new singleton());
    if (instance) return instance;

    throw std::runtime_error("Critical Error: Singleton mode failed!");
}
```

### 4.7 关于析构部分

不论是在4.1小节还是在4.6小节，都使用了声明定义静态局部变量的方式来实现单例的自动析构，原因是：

- 静态局部变量存放在内存的全局数据区。函数结束时，静态局部变量不会消失，每次该函数调用 时，也不会为其重新分配空间。它始终驻留在全局数据区，直到程序运行结束。
- 虽然静态局部变量与全局变量共享全局数据区，但静态局部变量只在定义它的函数中可见。

静态局部变量的生命周期是整个程序的运行时间，当程序结束时，会自动调用静态局部变量的析构函数（4.1 中的`class releasePointer`对象的析构）或者由智能指针自动完成释放（4.6 中的`static auto instance = std::shared_ptr<singleton>(new singleton())`）。
