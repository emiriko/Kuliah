import sys  # Mengimport system untuk exit program apabila user meminta EXIT

class _DoublyLinkedBase:
  """A base class providing a doubly linked list representation."""

  class _Pointer:
    """ A class for moving Pointers """
    def __init__(self, head, tail): 
      """ Constructor """
      self._headPointer = head # Ambil dari head
      self._tailPointer = tail # Ambil dari tail
      self._target = head # Bermulai dari head

    def _move_prev(self, steps):
      while(steps > 0): # Looping sampai step selesai
        if(self._target == self._headPointer): # Apabila pointer ingin step previous sebelum head, akan error
          raise IndexError("Steps out of bound error")
        else:
          self._target = self._target._prev # Mengubah pointer menuju arah head
        steps -= 1 # Decrease

    def _move_next(self, steps):
      while(steps > 0): # Looping sampai step selesai
        if(self._target == self._tailPointer): # Apabila pointer ingin step previous sebelum head, akan error
          raise IndexError("Steps out of bound error")
        else:
          self._target = self._target._next # Mengubah pointer menuju arah tail
        steps -= 1 # Decrease

  #-------------------------- nested _Node class --------------------------
  # nested _Node class
  class _Node:
    """Lightweight, nonpublic class for storing a doubly linked node."""
    
    def __init__(self, element, prev, next):            # initialize node's fields
      self._element = element                           # user's element
      self._prev = prev                                 # previous node reference
      self._next = next                                 # next node reference

  #-------------------------- list constructor -------------------------

  def __init__(self):
    """Create an empty list."""
    self._head = self._Node(None, None, None) # Empty node hanya sebagai ujung awal
    self._tail = self._Node(None, None, None) # Empty node hanya sebagai ujung akhir
    self._head._next = self._tail                  # tail is after head
    self._tail._prev = self._head                  # head is before tail
    self._size = 0                                 # number of elements  
    self._pointer = self._Pointer(self._head, self._tail) # Pointer
  #-------------------------- public accessors --------------------------

  def __len__(self):
    """Return the number of elements in the list."""
    return self._size

  def is_empty(self):
    """Return True if list is empty."""
    return self._size == 0

  def exit(self):
    """ Exit program once this function is called """
    sys.exit()

  #-------------------------- nonpublic utilities --------------------------
  def _insert_head(self, e):
    """ Adding new node right after the head node"""
    predecessor = self._head # Predecessor = batas bawah
    successor = self._head._next # Successor = batas atas
    newest = self._Node(e, predecessor, successor) # linked to neighbors
    predecessor._next = newest # Hubungkan predecessor (batas bawah dengan yang baru)
    successor._prev = newest # Hubungkan successor (batas atas dengan yang baru)
    self._size += 1 # Menambahkan panjang 
    return newest
  
  def _remove_head(self):
    """ Removing node right after the head node"""
    predecessor = self._head # Predecessor = batas bawah
    currentNode = self._head._next # Current_node = node yang sekarang
    successor = self._head._next._next # Successor = batas atas
    predecessor._next = successor # Hubungkan predecessor (batas bawah dengan batas atas karena sudah dihapus)
    successor._prev = predecessor # Hubungkan successor (batas bawah dengan batas bawah karena sudah dihapus)
    self._size -= 1 
    element = currentNode._element
    if(currentNode == self._pointer._target): # Apabila Pointernya berada di node tersebut 
      self._pointer._target = self._head # Ubah posisi pointer jadi head
    currentNode._prev = currentNode._next = currentNode._element = None # deprecate node

    return element

  def _insert_tail(self, e):
    """ Adding new node right before the tail node"""
    predecessor = self._tail._prev # Predecessor = batas bawah
    successor = self._tail # Successor = batas atas
    newest = self._Node(e, predecessor, successor)      # linked to neighbors
    predecessor._next = newest # Hubungkan predecessor (batas bawah dengan yang baru)
    successor._prev = newest # Hubungkan successor (batas atas dengan yang baru)
    self._size += 1 # Menambahkan panjang 
    return newest

  def _remove_tail(self):
    """ Removing node right before the tail node"""
    predecessor = self._tail._prev._prev # Predecessor = batas bawah
    currentNode = self._tail._prev # Current_node = node yang sekarang
    successor = self._tail # Successor = batas atas
    predecessor._next = successor # Hubungkan predecessor (batas bawah dengan batas atas karena sudah dihapus)
    successor._prev = predecessor # Hubungkan successor (batas bawah dengan batas bawah karena sudah dihapus)
    self._size -= 1
    element = currentNode._element
    if(currentNode == self._pointer._target): # Apabila Pointernya berada di node tersebut 
      self._pointer._target = self._tail # Ubah posisi pointer jadi tail
    currentNode._prev = currentNode._next = currentNode._element = None      # deprecate node
    return element
  
  def _remove_node_using_pointer_prev(self):
    """ Removing node before the pointer node """
    if(self._pointer._target == self._head): # Apabila pointer node sekarang adalah head
      raise SyntaxError("Head do not have previous node") 
    elif(self._pointer._target._prev == self._head): # Apabila pointer yang ingin dihapus adalah head
      raise SyntaxError("Unable to remove head or tail")
    predecessor = self._pointer._target._prev._prev # Predesessor merupakan 2 node sebelum node pointer
    successor = self._pointer._target # Successor merupakan pointer ini
    element = self._pointer._target._prev._element # record deleted element
    self._pointer._target._prev._prev = self._pointer._target._prev._next = self._pointer._target._prev._element = None  # deprecate node
    predecessor._next = successor # Hubungkan 
    successor._prev = predecessor
    self._size -= 1 
    return element     

  def _remove_node_using_pointer_next(self):
    """ Removing node after the pointer node """
    if(self._pointer._target == self._tail): # Apabila pointer node sekarang adalah tail
      raise SyntaxError("Tail do not have next node")
    elif(self._pointer._target._next == self._tail): # Apabila pointer node yang ingin dihapus adalah tail
      raise SyntaxError("Unable to remove head or tail")
    predecessor = self._pointer._target # Predecessor merupakan pointer ini
    successor = self._pointer._target._next._next # Successor merupakan 2 node sebelum node pointer
    element = self._pointer._target._next._element
    self._pointer._target._next._prev = self._pointer._target._next._next = self._pointer._target._next._element = None # deprecate node 
    predecessor._next = successor # Hubungkan
    successor._prev = predecessor # Hubungkan
    self._size -= 1 
    return element  

  def _insert_node_using_pointer_prev(self, e):
    """ Adding nodes before the pointer node"""
    successor = self._pointer._target 
    if(successor != self._head): # Apabila pointer bukan head maka tambahkan node baru
      predecessor = self._pointer._target._prev
      newest = self._Node(e, predecessor, successor)      # linked to neighbors
      predecessor._next = newest
      successor._prev = newest
      self._size += 1
      return newest
    else:
      raise IndexError("Insertion out of bound error")
    
  def _insert_node_using_pointer_next(self, e):
    """ Adding nodes after the pointer node """
    predecessor = self._pointer._target
    if(predecessor != self._tail): # Apabila pointer node tersebut bukan tail maka tambahkan node baru disebelah kanan pointer
      successor = self._pointer._target._next
      newest = self._Node(e, predecessor, successor)      # linked to neighbors
      predecessor._next = newest
      successor._prev = newest
      self._size += 1
      return newest
    else:
      raise IndexError("Insertion out of bound error")
  
  def __str__(self) -> str:
    """ Function to show the output """
    temp = ""
    nodeTemp = self._head

    while(nodeTemp != self._tail): # While loop sampai tail
      if(nodeTemp == self._pointer._target):
        if(nodeTemp == self._head):
          temp += f"['_HEAD' (P)]"
        elif(nodeTemp == self._tail):
          temp += f"['_TAIL' (P)]"
        else:
          temp += f"['{nodeTemp._element}' (P)]"
      else:
        if(nodeTemp == self._head):
          temp += f"['_HEAD']"
        elif(nodeTemp == self._tail):
          temp += f"['_TAIL']"
        else:
          # print(nodeTemp._element)
          temp += f"['{nodeTemp._element}']"
      
      temp += "<->"
      nodeTemp = nodeTemp._next
    if(nodeTemp == self._pointer._target):
      if(nodeTemp == self._tail):
        temp += f"['_TAIL' (P)]"
    else:
        if(nodeTemp == self._tail):
          temp += f"['_TAIL']"

    return temp

linked_list = _DoublyLinkedBase() # Make new instance of DoublyLinkedBase

while True:
  try:
    inputReal = input() # Menerima input
    inp = inputReal.strip().split() # Membagi input
    if(len(inp) < 1): # Apabila tidak ada input
      raise SyntaxError("Syntax error")
    else: 
      command = inp[0] # Meminta perintah pertama
      if(command != "EXIT"): # Apabila exit
        print(inputReal)
      if(command == "INSERT_HEAD"): # Apabila insert_head
        print("    Before:") 
        print(f"    {linked_list}\n")
        if(len(inp) != 2): # Apabila inputnya bukan mengikuti format INSERT_HEAD [VALUE]
          raise SyntaxError("Syntax error")
        else:
          value = inp[1]
          linked_list._insert_head(value) # Masukkan value sebagai node
          print("    After:")
          print(f"    {linked_list}\n")
      elif(command == "REMOVE_HEAD"): # Apabila remove head
        print("    Before:")
        print(f"    {linked_list}\n")
        if(linked_list.is_empty()): # Apabila hanya tail dan head
          raise SyntaxError("Unable to remove head or tail")
        else: # Apabila tidak
          linked_list._remove_head() # Remove node setelah head 
          print("    After:")
          print(f"    {linked_list}\n")
      elif(command == "INSERT_TAIL"):
        print("    Before:")
        print(f"    {linked_list}\n")
        if(len(inp) != 2): # Apabila inputnya bukan mengikuti format INSERT_TAIL [VALUE]
          raise SyntaxError("Syntax error")
        else: 
          value = inp[1]
          linked_list._insert_tail(value) # Masukkan node sebelum tail
          print("    After:")
          print(f"    {linked_list}\n")
      elif(command == "REMOVE_TAIL"):
        print("    Before:")
        print(f"    {linked_list}\n")
        if(linked_list.is_empty()): # Apabila hanya ada head dan tail
          raise SyntaxError("Unable to remove head or tail")
        else: # Apabila tidak
          linked_list._remove_tail() # Hilangkan node sebelum tail
          print("    After:")
          print(f"    {linked_list}\n")
      elif(command == "INSERT_NODE_USING_POINTER"):
        print("    Before:")
        print(f"    {linked_list}\n")
        if(len(inp) != 3): # Apabila inputnya bukan mengikuti format INSERT_NODE_USING_POINTER [ARAH] [VALUE]
          raise SyntaxError("Syntax error")
        else: 
          try:
            arah = inp[1] # Arah
            element = inp[2] # Value
            if(arah != "PREV" and arah != "NEXT"): # Apabila arah bukan prev atau next
              raise SyntaxError("Syntax error")
            else:
              if(arah == "PREV"): # Apabila prev
                linked_list._insert_node_using_pointer_prev(element) # Masukkan node sebelum pointer
              else:
                linked_list._insert_node_using_pointer_next(element) # Masukkan node setelah pointer
              print("    After:")
              print(f"    {linked_list}\n")
          except ValueError:
            raise SyntaxError("Syntax error")
      elif(command == "REMOVE_NODE_USING_POINTER"): 
        print("    Before:")
        print(f"    {linked_list}\n")
        if(len(inp) != 2): # Apabila inputnya bukan mengikuti format REMOVE_NODE_USING_POINTER [ARAH]
          raise SyntaxError("Syntax error")
        else:
          arah = inp[1] 
          if(arah != "PREV" and arah != "NEXT"): # Apabila bukan PREV atau NEXT
            raise SyntaxError("Syntax error")
          else:
            if(arah == "PREV"): # Apabila prev
              linked_list._remove_node_using_pointer_prev() # Remove node sebelum pointer node
            else: # Apabila NEXT
              linked_list._remove_node_using_pointer_next() # Remove node setelah pointer node
            print("    After:")
            print(f"    {linked_list}\n")
      elif(command == "MOVE_POINTER"): 
        print("    Before:")
        print(f"    {linked_list}\n")
        if(len(inp) != 3): # Apabila inputnya bukan mengikuti format MOVE_POINTER [ARAH] [STEPS]
          raise SyntaxError("Syntax error")
        else:
          try:
            arah = inp[1] # Arah
            steps = int(inp[2]) # Step (harus int) dan bilangan positif
            if((arah != "PREV" and arah != "NEXT") or steps <= 0): # Apabila tidak memenuhi
              raise SyntaxError("Syntax error")
            else: 
              if(arah == "PREV"): # Apabila prev
                linked_list._pointer._move_prev(steps) # Ubah pointer menuju head sesuai dengan step
              else:
                linked_list._pointer._move_next(steps) # Ubah pointer menuju tail sesuai dengan step
              print("    After:")
              print(f"    {linked_list}\n")
          except ValueError:
            raise SyntaxError("Syntax error")
      elif(command == "IS_EMPTY"):
        hasil = "TRUE" # Default = Empty
        if(linked_list.is_empty()): # Kalau empty
          hasil = "TRUE"
        else: # Kalau ada node didalam
          hasil = "FALSE"
        print(f"    {hasil}\n")
      elif(command == "SIZE"): # Hitung size
        print(f"    {len(linked_list)}\n")
      elif(command == "EXIT"): # Se;esaikan program
        linked_list.exit()
      else: 
        raise SyntaxError("Syntax error")
  except (SyntaxError, IndexError, ValueError) as e:
    print(f"    {e}\n")  # Exception handling error
